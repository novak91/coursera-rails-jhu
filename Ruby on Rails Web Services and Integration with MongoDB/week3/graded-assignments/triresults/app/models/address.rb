class Address
  attr_accessor :city, :state, :location
  
  def initialize(city=nil, state=nil, location=nil)
    @city = city
    @state = state
    if location.nil?
      @location = Point.new(0.0, 0.0)
    else
      @location = Point.new(location[:coordinates][0], location[:coordinates][1])
    end
  end
  
  def self.demongoize(object)
    case object
    when nil then nil
    when Hash then Address.new(object[:city], object[:state], object[:loc])
    when Address then object
    end
  end
  
  def mongoize
    return {:city => @city, :state => @state, :loc => {:type => "Point", :coordinates =>[@location.longitude, @location.latitude]} }
  end
  
  def self.mongoize(object)
    case object
    when Address then {:city => object.city, :state => object.state, :loc => {:type => "Point", :coordinates =>[object.location.longitude, object.location.latitude]}}
    when Hash then {:city => object[:city], :state => object[:state], :loc => object[:loc]}
    when nil then nil
    end
  end
  
  def self.evolve(object)
    case object
    when Address then object.mongoize
    else object
    end
  end
end