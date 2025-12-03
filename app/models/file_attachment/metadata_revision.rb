# This model is immutable
class FileAttachment::MetadataRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User"

  def readonly?
    !new_record?
  end
end
