class Place
  include Mongoid::Document
  include ActiveModel::Model

  attr_accessor :id, :formatted_address, :location, :address_components
  
  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client['places']
  end
  
  def self.load_all(file_path)
    file = JSON.parse(file_path.read)
    collection.insert_many(file)
  end

  def initialize(params)
    @id = params[:_id].to_s
    @formatted_address = params[:formatted_address]
    @location = Point.new(params[:geometry][:geolocation])
    @address_components = params[:address_components].map{ |a| AddressComponent.new(a)} if !params[:address_components].nil? 
  end

  def self.find_by_short_name(name)
    collection.find(:'address_components.short_name' => name)
  end

  def self.to_places(places)
    places.map { |p| Place.new(p) }
  end

  def self.find(place_id)
    id = BSON::ObjectId.from_string(place_id)
    doc = collection.find(:_id => id).first
    
    if !doc.nil?
      Place.new(doc)
    end
  end
  
  def self.all(offset = 0, limit = 0)
    doc = collection.find({}).skip(offset)
    doc = doc.limit(limit) if !limit.nil?
    doc = to_places(doc)
  end

  def destroy
    collection.find(:_id => BSON::ObjectId.from_string(@id)).delete_one
  end
  
  def self.get_address_components(sort = nil, offset = 0, limit = 0)
    pipeline = [
      { :$unwind => "$address_components" },
      {
        :$project => {
          :_id => 1, 
          :address_components => 1, 
          :formatted_address => 1, 
          :'geometry.geolocation' => 1 }
      }
    ]
    pipeline.push({:$sort=>sort}) if !sort.nil?
    pipeline.push({:$skip=>offset}) if offset != 0
    pipeline.push({:$limit=>limit}) if limit != 0
    collection.find.aggregate(pipeline) 
  end
  
  def self.get_country_names
    pipeline = [
      { :$unwind => "$address_components" },
      {
        :$project => {
          :_id => 0,
          :'address_components.long_name' => 1,
          :'address_components.types' => 1 }
      },
      { :$match => { :"address_components.types" => "country" } },
      { :$group => { :"_id" => '$address_components.long_name' } }
    ]
    documents = collection.find.aggregate(pipeline)
    documents.to_a.map {|h| h[:_id]}
  end
  
  def self.find_ids_by_country_code(country_code)
    pipeline = [
      { :$match => { 
          :'address_components.types' => "country",
          :'address_components.short_name' => country_code
        }
      },
      {
        :$project => {
          :_id => 1
        }
      }
    ]
    documents = collection.find.aggregate(pipeline)
    documents.to_a.map { |h| h[:_id].to_s}
  end
  
  def self.create_indexes
    collection.indexes.create_one({:'geometry.geolocation'=>Mongo::Index::GEO2DSPHERE})
  end
  
  def self.remove_indexes
    collection.indexes.drop_all
  end
  
  def self.near(point, max_meters = nil)
    pipeline = {
      :'geometry.geolocation' => {
        :$near => {
          :$geometry => point.to_hash,
          :$maxDistance => max_meters
        }
      }
    }
    collection.find(pipeline)
  end
  
  def near(max_distance=nil)
      self.class.to_places(self.class.near(@location, max_distance))
  end

  def photos(offset = 0, limit = nil)
    photos = Photo.find_photos_for_place(@id).skip(offset)
    photos = photos.limit(limit) if !limit.nil?
    if !photos.nil?
      result = photos.map { |photo| Photo.new(photo) }
    else
      result = []
    end
  end

  def persisted?
    !@id.nil?
  end

end
