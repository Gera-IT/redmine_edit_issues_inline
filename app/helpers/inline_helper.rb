module InlineHelper
  include ApplicationHelper

  unloadable


  def self.define_type(column)
    name = column.name
    restricted_attributes = [:relations, :created_at, :updated_at, :closed_on, :id]
    allowed_attributes = [:tracker, :status, :priority, :subject, :assigned_to, :category, :fixed_version, :estimated_hours, :start_date, :due_date, :position, :remaining_hours, :project, :author]
    return :custom_field if name.to_s.include?("cf_")
    return :bool if column.name == :is_private
    return :uneditable_field if restricted_attributes.include?(name)
    return :uneditable_field unless allowed_attributes.include?(name)
    if allowed_attributes.include?(name)
      [:status, :priority, :tracker, :assigned_to, :category, :fixed_version, :project, :author].include?(name) ? :select : :input
    end

  end

  def self.read_only_column(column)
    true if self.define_type(column) == :custom_field || self.define_type(column) == nil
  end


  def self.get_collection(column_name, project_id)
    model = self.model_for_replace(column_name)
    if model == "Member"
      collection = self.get_project_users(project_id)
    elsif model == "Version"
      collection = Project.find(project_id).versions
    else
      collection = model.constantize.all
    end
    collection = collection.each_with_object({}){ |o,h| h[o.try(:id)] = o.try(:name) }
    collection[:nil] = 'None' if self.allowed_empty_fields(model)

    collection
  end

  def self.get_custom_field_collection(custom_field)
    collection = custom_field.possible_values.each_with_object({}){ |o,h| h[o] = o }
    collection
  end

  def self.find_custom_value_object(issue, column)
    column.custom_field.custom_values.find_by_customized_id(issue.id)
  end


  def self.generate_bip_params(issue, column, new_object=false)
    issue_custom_field = column.custom_field
    custom_value = issue_custom_field.custom_values.find_by_customized_id(issue.id)
    if issue_custom_field.field_format == "list"
      {:type => :select, :collection => InlineHelper.get_custom_field_collection(issue_custom_field),
          :path => Rails.application.routes.url_helpers.issue_path(issue), :data => {:user_object => "issue", :user_attribute => "custom_field_values[#{column.custom_field.id}]", :simple_value => issue_custom_field.custom_values.find_by_customized_id(issue.id).try(:value)}}
    else
      {:type => :input,
          :path => Rails.application.routes.url_helpers.issue_path(issue), :inner_class => '', :data => {:user_object => "issue", :user_attribute => "custom_field_values[#{column.custom_field.id}]"}}#, :activator => "#issue_#{issue.id}_#{column.name.to_s}"
    end
  end

  def self.allowed_empty_fields(field)
    allowed_fields = ["IssueCategory", "Version"]
    allowed_fields.include? field
  end

  def self.replace_attributes_name(field_name)
    values = {
        :status => :status_id,
        :priority => :priority_id,
        :tracker => :tracker_id,
        :assigned_to => :assigned_to_id,
        :category => :category_id,
        :fixed_version => :fixed_version_id,
        :project => :project_id,
        :author => :author_id
    }

    return values[field_name]
  end


  def self.model_for_replace(value)
    values = {
        :status => "IssueStatus",
        :priority => "IssuePriority",
        :tracker => "Tracker",
        :assigned_to => "Member",
        :category => "IssueCategory",
        :fixed_version => "Version",
        :project => "Project",
        :author => "User"
    }

    return values[value.to_sym] if value && value.respond_to?(:to_sym)
  end

  def self.get_project_users(project_id)
    Project.find(project_id).users.all
  end

end
