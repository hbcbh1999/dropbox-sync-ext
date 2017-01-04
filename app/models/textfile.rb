class Textfile < ApplicationRecord
  belongs_to :user
  mount_uploader :textfile, TextfileUploader
end
