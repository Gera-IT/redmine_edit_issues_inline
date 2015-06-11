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

  def self.page_issues_status(issues)
    issues_total_time = issues.map(&:estimated_hours).map(&:to_f)
    issues_total_time = issues_total_time.inject(:+)
    issues_total_time = 0 unless issues_total_time

    closed_issues_time = issues.select {|i| i.status.is_closed }.map(&:estimated_hours).map(&:to_f)
    closed_issues_time = closed_issues_time.inject(:+)
    closed_issues_time = 0 unless closed_issues_time
    opened_issues_time = issues_total_time - closed_issues_time
    status = {:opened => 0, :closed => 0}
    status[:opened] = issues.select{|i| !i.status.is_closed}.count
    status[:closed] = issues.select{|i| i.status.is_closed}.count
    return "(#{status[:opened]} open/ #{status[:closed]} closed); ETA-#{issues_total_time}h(#{opened_issues_time}h open/#{closed_issues_time}h closed)"
  end


  def self.get_collection(column_name, project_id)
    model = self.model_for_replace(column_name)
    if model == "Member"
      collection = self.get_project_users(project_id)
    elsif model == "Version"
      collection = Project.find(project_id).versions
    elsif model == "IssueCategory"
      collection = Project.find(project_id).issue_categories
    elsif model == "IssueStatus"
      collection = model.order("position ASC").all
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
    attrs = issue.custom_field_values
    attrs = issue.custom_values.each_with_object({}) do |o, h|
      possible_value = nil
      if o.custom_field.is_required && o.custom_field.field_format == "list"                         #this needs to avoid validation failing on empty object
        possible_value = o.custom_field.possible_values.first
      end
      possible_value = "" #unless possible_value

      h[o.custom_field_id ] = o.value || possible_value
    end
    attrs.delete(issue_custom_field.id)
    custom_value = issue_custom_field.custom_values.find_by_customized_id(issue.id)
    if issue_custom_field.field_format == "list"
      {:type => :select, :collection => InlineHelper.get_custom_field_collection(issue_custom_field),
          :path => Rails.application.routes.url_helpers.issues_inline_path(issue, :project_id => issue.project.id), :additional_attributes => attrs , :data => {:id => issue.id, :user_object => "issue", :user_attribute => "custom_field_values[#{column.custom_field.id}]", :additional_attributes_name => "custom_field_values", :simple_value => issue_custom_field.custom_values.find_by_customized_id(issue.id).try(:value)}}
    else
      {:type => :input,
          :path => Rails.application.routes.url_helpers.issues_inline_path(issue, :project_id => issue.project.id),  :additional_attributes => attrs, :inner_class => '', :data => {:id => issue.id, :user_object => "issue", :user_attribute => "custom_field_values[#{column.custom_field.id}]", :additional_attributes_name => "custom_field_values"}}
    end
  end

  def self.allowed_empty_fields(field)
    allowed_fields = ["IssueCategory", "Version", "Member"]
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
