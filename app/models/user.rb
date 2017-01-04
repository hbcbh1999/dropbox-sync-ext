class User < ApplicationRecord
  has_many :textfiles, :dependent => :destroy
  accepts_nested_attributes_for :textfiles

  def actions
    actions = []
    self.textfiles.each do |t|
      actions.push(t.textfile)
    end
    actions
  end
end
