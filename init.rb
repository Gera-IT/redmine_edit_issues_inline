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
  settings :default => {'enable_inline_edit' => '1'}, :partial => 'settings/inline_information'

  project_module :inline_edit do
    permission :allow_inline_edit, :issues_inline => :update_inline
  end




end


class JSCSSFilesHook < Redmine::Hook::ViewListener

    render_on :view_layouts_base_html_head, :partial => 'shared/js_includes'
end


