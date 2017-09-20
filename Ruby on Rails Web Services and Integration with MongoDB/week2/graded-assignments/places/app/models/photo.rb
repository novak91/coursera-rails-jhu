class Photo
  include Mongoid::Document
  require 'exifr/jpeg'
  
  attr_accessor :id, :location, :place
  attr_writer :contents


  def self.mongo_client
    Mongoid::Clients.default
  end
 
  def initialize(hash={})
    if !hash[:_id].nil?
      @id = hash[:_id].to_s
    else
      return false
    end
    if !hash[:metadata].nil?
      @location = Point.new(hash[:metadata][:location])
      @place = hash[:metadata][:place]
    end
  end

  def persisted?
    if !@id.nil?
      return true
    else
      return false
    end
  end
 
  def save
    if !persisted?
      gps = EXIFR::JPEG.new(@contents).gps

      description = {}
      description[:content_type] = 'image/jpeg'
      description[:metadata] = {}
      
      @location = Point.new(:lng => gps.longitude, :lat => gps.latitude)
      description[:metadata][:location] = @location.to_hash
      description[:metadata][:place] = @place

      if @contents
        @contents.rewind
        grid_file = Mongo::Grid::File.new(@contents.read, description)
        id = self.class.mongo_client.database.fs.insert_one(grid_file)
        @id = id.to_s
      end
    else
      self.class.mongo_client.database.fs.find(:_id => BSON::ObjectId(@id)).update_one(
        :$set => {
          :metadata => {
            :location => @location.to_hash,
            :place => @place
          }
        }
      )
     end
  end
   
  def self.all(offset = 0, limit = nil)
    documents = mongo_client.database.fs.find({}).skip(offset)
    if !limit.nil?
      documents = documents.limit(limit)
    end
    documents.map {|doc| Photo.new(doc)}     
  end

  def self.find(photo_id)
    id = BSON::ObjectId.from_string(photo_id)
    documents = mongo_client.database.fs.find(:_id => id).first
    if documents.nil?
      return nil
    else
      Photo.new(documents)
    end
  end
 
  def contents
    document = self.class.mongo_client.database.fs.find_one(:_id => BSON::ObjectId(@id))
    if document
        buffer = ""
        document.chunks.reduce([]) do |x, chunk|
          buffer << chunk.data.data
        end
    end
    return buffer
  end
  
  def destroy
      id = BSON::ObjectId.from_string(@id)
      self.class.mongo_client.database.fs.find(:_id => id).delete_one
  end 

  def find_nearest_place_id(maxdistance)
    place = Place.near(@location, maxdistance).limit(1).projection(:_id => 1).first
    if place == nil
      return nil
    else
      return place[:_id]
    end
  end

  def place
    if !@place.nil?
      Place.find(@place.to_s)
    end
  end

  def place=(place)
    if place.is_a?(Place)
      @place = BSON::ObjectId.from_string(place.id)
    elsif place.is_a?(String)
      @place = BSON::ObjectId.from_string(place)
    else
      @place = place
    end
  end

  def self.find_photos_for_place(place_id)
    if place_id.is_a?(BSON::ObjectId)
      new_id = place_id
    elsif place_id.is_a?(String)
      new_id = BSON::ObjectId.from_string(place_id.to_s)     
    end
    mongo_client.database.fs.find(:'metadata.place' => new_id)
  end
end
