class MgHelpDocument < ActiveRecord::Base
	has_attached_file :document
	validates_attachment_content_type :document, :content_type => []
end
