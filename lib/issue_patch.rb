require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a relationship
# Issue +belongs_to+ to Deliverable
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)


  end

  module ClassMethods

  end

  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the
    # Query and filtering

    def inline_issue_name
      "some_string"

    end

    def deliverable_subject
      unless self.deliverable.nil?
        return self.deliverable.subject
      end
    end
  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)
