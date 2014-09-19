class IssuesInlineController < ApplicationController

  before_filter :find_project_by_project_id

  def update_inline

    @issue = Issue.find_by_id(params[:issues_inline_id])


    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        format.html { redirect_to(@issue, :notice => 'Issue was successfully updated.') }
        format.json { respond_with_bip(@issue) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@issue) }
      end
    end

  end

end