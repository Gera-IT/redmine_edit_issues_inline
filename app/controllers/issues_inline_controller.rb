class IssuesInlineController < ApplicationController

  before_filter :find_project_by_project_id
  before_filter :get_issue, :only => [:update]



  # def update_inline
  #
  #   @respond_object = Issue.find_by_id(params[:issues_inline_id])
  #
  #
  #   if params[:need_object_value]
  #     model = InlineHelper.model_for_replace(params[:issue].keys.first.to_sym)
  #     if model == "Member"
  #       @respond_object.update_attributes!(:assigned_to => @respond_object.project.users.find(params[:issue].values.first.to_i))
  #     else
  #       object = eval(model).find_by_id(params[:issue].values.first.to_i)
  #       success = @respond_object.update_attribute(params[:issue].keys.first.to_sym, object)
  #
  #     end
  #   else
  #     if params[:type] == "custom_field"
  #       @respond_object = CustomField.find(params[:custom_field_id].to_i).custom_values.find_or_initialize_by_customized_id(params[:issues_inline_id].to_i)
  #       @respond_object.send("#{params[:custom_value].keys.first}=", params[:custom_value].values.first.to_s)
  #       success = @respond_object.save
  #     else
  #       success = @respond_object.update_attributes(params[:issue])
  #     end
  #
  #   end
  #
  #
  #   respond_to do |format|
  #     if success
  #       p "Issue was updated"
  #       format.html { redirect_to(@respond_object, :notice => 'Issue was successfully updated.') }
  #       format.json { respond_with_bip(@respond_object) }
  #     else
  #       p 'Failure, issue wasnt updated'
  #       format.html { render :action => "edit" }
  #       format.json { respond_with_bip(@respond_object) }
  #     end
  #   end
  #
  # end


  def update
    return unless update_issue_from_params
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    saved = false
    begin
      saved = save_issue_with_child_records
    rescue ActiveRecord::StaleObjectError
      @conflict = true
      if params[:last_journal_id]
        @conflict_journals = @issue.journals_after(params[:last_journal_id]).all
        @conflict_journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
      end
    end

    if saved
      render_attachment_warning_if_needed(@issue)
      flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?

      respond_to do |format|
        format.html { redirect_back_or_default issue_path(@issue) }
        format.json { respond_with_bip(@issue) }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.json { respond_with_bip(@issue, true)   }
        format.api  { render_validation_errors(@issue) }
      end
    end
  end

  private

  def save_issue_with_child_records
    Issue.transaction do
      if params[:time_entry] && (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) && User.current.allowed_to?(:log_time, @issue.project)
        time_entry = @time_entry || TimeEntry.new
        time_entry.project = @issue.project
        time_entry.issue = @issue
        time_entry.user = User.current
        time_entry.spent_on = User.current.today
        time_entry.attributes = params[:time_entry]
        @issue.time_entries << time_entry
      end

      call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
      if @issue.save
        call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
      else
        p "ERRORS"
        p @issue.errors
        raise ActiveRecord::Rollback
      end
    end
  end

  def update_issue_from_params
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    @time_entry.attributes = params[:time_entry]

    @issue.init_journal(User.current)

    issue_attributes = params[:issue]
    if issue_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
        when 'overwrite'
          issue_attributes = issue_attributes.dup
          issue_attributes.delete(:lock_version)
        when 'add_notes'
          issue_attributes = issue_attributes.slice(:notes)
        when 'cancel'
          redirect_to issue_path(@issue)
          return false
      end
    end
    @issue.safe_attributes = issue_attributes
    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    true
  end

  def get_issue
    @issue = Issue.find_by_id(params[:issues_inline_id])
    raise Unauthorized unless @issue.visible?
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end