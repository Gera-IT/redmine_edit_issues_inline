module InlineHelper
  include ApplicationHelper

  unloadable


  def self.define_type(column)
    name = column.name
    case name
      when :status, :priority, :tracker, :assigned_to, :category, :fixed_version
        :select
      else
        :input
    end

  end

  def self.get_collection(column_name, project_id)
    model = self.model_for_replace(column_name)
    p 'inline_helper.rb:20'
    p 'MODEL NAME'
    p model
    if model == "Member"
      collection = self.get_project_users(project_id)
    elsif model == "Version"
      collection = Project.find(project_id).versions
    else
      p 'inline_helper.rb:26'
      p 'before_collection'
      collection = model.constantize.all
    end
    collection = collection.each_with_object({}){ |o,h| h[o.try(:id)] = o.try(:name) }
    collection[:nil] = 'None' if self.allowed_empty_fields(model)

    collection
  end

  def simple_value(issue, column_name)


  end

  def self.allowed_empty_fields(field)
    allowed_fields = ["IssueCategory", "Version"]
    allowed_fields.include? field
  end


  def self.model_for_replace(value)
    values = {
        :status => "IssueStatus",
        :priority => "IssuePriority",
        :tracker => "Tracker",
        :assigned_to => "Member",
        :category => "IssueCategory",
        :fixed_version => "Version"
    }

    return values[value.to_sym] if value && value.respond_to?(:to_sym)
  end

  def self.get_project_users(project_id)
    Project.find(project_id).users.all
  end

end
