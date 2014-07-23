class Note < ActiveRecord::Base
  include ActiveRecord::UnionScope
  belongs_to :creator, class_name: "Member"
  belongs_to :commentable, polymorphic: true
  scope :commentable, Proc.new {|ids,type| where(commentable_id: ids, commentable_type: type) }
end
