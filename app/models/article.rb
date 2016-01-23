class Article < ActiveRecord::Base
	include AASM

	belongs_to			:user
	has_many			:comments
	has_many  			:has_categories
	has_many			:categories, through: :has_categories
	has_attached_file	:cover, styles: { medium: "1280x720", thumb: "800x600", mini: "400x200"}

	validates :title, presence: true, uniqueness: true
	validates :body, presence: true, length: { minimum: 20}
	validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/
				
	before_save :set_visits_count
	after_create :save_categories
	after_create :send_mail

	def update_visits_count
		self.save if self.visits_count.nil?
		self.update(visits_count: self.visits_count + 1)
	end

	scope	:publicados, ->{ where(state: "published") }
	scope	:ultimos, ->{ order("created_at DESC").limit(10) }

	# def self.publicados
	# 	Article.where(state: "published")
	# end

	#Custom setter
	def categories=(value)
		@categories = value
	end

	aasm column: 'state' do
		state	:in_draft, initial: true
		state	:published

		event	:publish do 
			transitions from: :in_draft, to: :published
		end

		event	:unpublish do 
			transitions from: :published, to: :in_draft
		end
	end

	private

	def save_categories
		unless @categories.nil?
			@categories.each do |category_id|
				HasCategory.create(category_id: category_id, article_id: self.id)
			end
		end
	end

	def set_visits_count
		self.visits_count ||= 0
	end

	def send_mail
		ArticleMailer.new_article(self).deliver_later
	end

end
