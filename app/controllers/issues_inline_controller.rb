class IssuesInlineController < ApplicationController

  before_filter :find_project_by_project_id



  def update_inline

    @issue = Issue.find_by_id(params[:issues_inline_id])


    if params[:need_object_value]
      model = InlineHelper.model_for_replace(params[:issue].keys.first.to_sym)
      if model == "Member"
        @issue.update_attributes!(:assigned_to => @issue.project.users.find(params[:issue].values.first.to_i))
      else
        object = eval(model).find_by_id(params[:issue].values.first.to_i)
        success = @issue.update_attribute(params[:issue].keys.first.to_sym, object)
      end
    else
      success = @issue.update_attributes(params[:issue])
    end


    respond_to do |format|
      if success
        p "Issue was updated - field: #{params[:issue].keys.first} with object #{object.inspect if object}"
        format.html { redirect_to(@issue, :notice => 'Issue was successfully updated.') }
        format.json { respond_with_bip(@issue) }
      else
        p 'Failure, issue wasnt updated'
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@issue) }
      end
    end

  end

end