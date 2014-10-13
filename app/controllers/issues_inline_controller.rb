class IssuesInlineController < ApplicationController

  before_filter :find_project_by_project_id



  def update_inline

    @respond_object = Issue.find_by_id(params[:issues_inline_id])


    if params[:need_object_value]
      model = InlineHelper.model_for_replace(params[:issue].keys.first.to_sym)
      if model == "Member"
        @respond_object.update_attributes!(:assigned_to => @respond_object.project.users.find(params[:issue].values.first.to_i))
      else
        object = eval(model).find_by_id(params[:issue].values.first.to_i)
        success = @respond_object.update_attribute(params[:issue].keys.first.to_sym, object)

      end
    else
      if params[:type] == "custom_field"
        @respond_object = CustomField.find(params[:custom_field_id].to_i).custom_values.find_by_customized_id(params[:issues_inline_id].to_i)
        p 'INSIDE CUSTOM_FIELD'
        p @respond_object
        success = @respond_object.update_attribute(params[:custom_value].keys.first.to_sym, params[:custom_value].values.first.to_sym)
      else
        success = @respond_object.update_attributes(params[:issue])
      end

    end


    respond_to do |format|
      if success
        p "Issue was updated"
        format.html { redirect_to(@respond_object, :notice => 'Issue was successfully updated.') }
        format.json { respond_with_bip(@respond_object) }
      else
        p 'Failure, issue wasnt updated'
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@respond_object) }
      end
    end

  end

end