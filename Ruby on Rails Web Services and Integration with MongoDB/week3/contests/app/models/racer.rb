class Racer
  include Mongoid::Document
  
  field :first_name, as: :fn, type: String
  field :last_name, as: :ln, type: String
  field :date_of_birth, as: :dob, type: Date
  
  embeds_one :primary_address, as: :addressable, class_name: 'Address'
  #has_many :races, class_name: 'Entrant'
  has_one :medical_record, dependent: :destroy
  
  validates_presence_of :first_name, :last_name
  
  def races
    Contest.where(:"entrants.racer_id"=>self.id).map {|m| m.entrants.where(:racer_id=>self.id).first}
  end
end
