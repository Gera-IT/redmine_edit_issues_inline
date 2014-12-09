require 'assets_hook'
require 'redmine'

require_dependency 'issue_patch'


Redmine::Plugin.register :redmine_edit_issues_inline do
  name 'Redmine inline issues edit plugin'
  author 'Alex Sinelnikov'
  description 'Inline edit for fields on tasks list'
  version '1.0b'
  url 'https://github.com/avdept/redmine_edit_issues_inline'
  author_url 'https://github.com/avdept'

  settings :default => {'inline_issues_information' => '1'}, :partial => 'settings/inline_information'

  project_module :inline_edit do
    permission :allow_inline_edit, :issues_inline => :update_inline
  end




end


class FilesHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = { })
    javascript_include_tag('best_in_place.js', :plugin => 'redmine_edit_issues_inline') +
        javascript_include_tag('inline_edit.js', :plugin => 'redmine_edit_issues_inline')
  end
end


