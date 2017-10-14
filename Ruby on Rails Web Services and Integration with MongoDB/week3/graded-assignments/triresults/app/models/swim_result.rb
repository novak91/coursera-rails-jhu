class SwimResult < LegResult
  include Mongoid::Document
  
  field :pace_100, as: :pace_100, type: Float
  
  def calc_ave
    if event && secs
      meters = event.meters
      if !meters.nil?
        self.pace_100 = (secs/ (meters/100))
      else
        nil
      end
    end
  end
end