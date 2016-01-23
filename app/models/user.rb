class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many	:articles
  has_many	:comments

  include PermissionsConcern

  def avatar
  	email_address = self.email.downcase

  	hash = Digest::MD5.hexdigest(email_address)

  	image_src = "http://www.gravatar.com/avatar/#{hash}"
  end

end
