class Draft < ActiveRecord::Base
  belongs_to :user
  belongs_to :draftable, polymorphic: true

  validates :user, presence: true
  validates :draftable, presence: true
end
