require 'assets_hook'
require 'redmine'

require_dependency 'issue_patch'

# require_dependency 'issues_inline_helper'

# require_dependency 'inline_helper'

Redmine::Plugin.register :redmine_edit_issues_inline do
  name 'Redmine inline issues edit plugin'
  author 'Alex Sinelnikov'
  description 'Inline edit for fields on tasks list'
  version '1.0b'
  url 'https://github.com/avdept/redmine_edit_issues_inline'
  author_url 'https://github.com/avdept'

  project_module :inline_edit do
    permission :allow_inline_edit, :issues_inline => :update_inline
  end




end



