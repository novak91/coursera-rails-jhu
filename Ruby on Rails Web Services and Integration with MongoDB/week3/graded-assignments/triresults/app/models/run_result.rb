class RunResult < LegResult
  include Mongoid::Document
  
  field :mmile, as: :minute_mile, type: Float
  
  def calc_ave
    if event && secs
      miles = event.miles
      if !miles.nil?
        self.mmile = ((secs/60)/miles)
      else
        nil
      end
    end
  end
end