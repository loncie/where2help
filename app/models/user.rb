class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable

  # start @informatom 20151016
  #:confirmable, :omniauthable
  # end @informatom 20151016

  include DeviseTokenAuth::Concerns::User
  include AdminConfirmable

  # associations
  has_many :volunteerings
  has_many :appointments, through: :volunteerings, source: :need
  has_many :needs

  # validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :organization, presence: true, if: :registered_as_ngo?
  validates :phone, presence: true
  validates :terms_and_conditions, acceptance: true

  # callbacks
  after_create :first_user_gets_admin

  # instance methods
  def role
    case
    when admin?
      :admin
    when ngo_admin?
      :ngo
    else
      :volunteer
    end
  end

  private

  def first_user_gets_admin
    if User.all.count == 1
      self.update(admin: true)
    end
  end

  def registered_as_ngo?
    ngo_admin
  end
end
