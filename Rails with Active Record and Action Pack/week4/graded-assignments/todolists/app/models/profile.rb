class Profile < ActiveRecord::Base
  belongs_to :user
  
  validate :first_or_last_name_present
  validates :gender, inclusion: ["male", "female"]
  validate :no_sue_male
  
  def first_or_last_name_present
    if first_name.nil? && last_name.nil?
      errors.add(:base, "Either first name or last name must be filled in")
    end
  end
  
  def no_sue_male
    if gender == "male" && first_name == "Sue"
      errors.add(:base, "Sue cannot be male")
    end
  end
  
  def self.get_all_profiles (min, max)
    Profile.where("birth_year BETWEEN :min_year AND :max_year", min_year: min, max_year: max).order(:birth_year).to_a
  end
end
