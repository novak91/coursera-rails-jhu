class Entrant
  include Mongoid::Document
  
  field :_id, type: Integer
  field :name, type: String
  field :group, type: String
  field :secs, type: Float
  
  belongs_to :racer, validate: true
  embedded_in :contest

  before_create do |doc|
    racername=doc.racer
    if racername
      doc.name="#{racername.last_name}, #{racername.first_name}"
    end
  end
  
end
