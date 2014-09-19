require 'assets_hook'


Redmine::Plugin.register :task_inline_edit do
  name 'Task Inline Edit plugin'
  author 'Alex Sinelnikov'
  description 'Inline edit for fields on tasks list'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :inline_edit do
    permission :allow_inline_edit, :issues_inline => :update_inline
  end


end



