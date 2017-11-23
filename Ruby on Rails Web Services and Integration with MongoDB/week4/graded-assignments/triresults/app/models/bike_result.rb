class BikeResult < LegResult
  include Mongoid::Document
  
  field :mph, as: :mph, type: Float
  
  def calc_ave
    if event && secs
      miles = event.miles
      if !miles.nil?
        self.mph = (miles*3600 / secs)
      else
        nil
      end
    end
  end
end