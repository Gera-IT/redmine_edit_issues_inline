class FilesHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = { })
    javascript_include_tag('best_in_place.js', :plugin => 'task_inline_edit') +
    javascript_include_tag('inline_edit.js', :plugin => 'task_inline_edit')
  end
end