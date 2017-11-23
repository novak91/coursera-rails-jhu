class Placing
  attr_accessor :name, :place
  
  def initialize (name, place)
    @name = name
    @place = place
  end
  
  def self.demongoize(object)
    case object
    when nil then nil
    when Hash then Placing.new(object[:name], object[:place])
    when Placing then object
    end
  end  
  
  def mongoize
    return {:name => @name, :place => @place }
  end
  
  def self.evolve(object)
    case object
    when Placing then object.mongoize
    else object
    end
  end
end