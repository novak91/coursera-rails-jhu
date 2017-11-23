module Api
  class EntriesController < ApplicationController
    
    def index     
     if !request.accept || request.accept == "*/*"
        render plain: api_racer_entries_path
      else

     end
    end
    
    def show
      if !request.accept || request.accept == "*/*"
        render plain: api_racer_entry_path(params[:racer_id], params[:id])
      else

      end
    end
    
  end
end