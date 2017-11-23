module Api
  class RacesController < ApplicationController
    before_action :set_race, only: [:show, :edit, :update, :destroy]
    #before_action :set_race, only: [:show, :edit, :update, :destroy]
    # GET /api/races
    # GET /api/races.json

    rescue_from Mongoid::Errors::DocumentNotFound do |exception|
      @msg = "woops: cannot find race[#{params[:id]}]"
      if !request.accept || request.accept == "*/*"
        render plain: @msg, status: :not_found
      else
        render action: :error, status: :not_found
      end
    end

    rescue_from ActionView::MissingTemplate do |exception|
      Rails.logger.debug exception
      @msg = "woops: we do not support that content-type[#{request.accept}]"
      render plain: @msg, status: 415
    end

    def index
      if !request.accept || request.accept == "*/*"
        render plain: "#{api_races_path}, offset=[#{params[:offset]}], limit=[#{params[:limit]}]"
      else

      end
    end

    def show
      if !request.accept || request.accept == "*/*"
        render plain: api_race_path(params[:id]), status: :ok
      else
        @race = Race.find(params[:id])
        render :race, status: :ok
      end
    end

    def create
      if !request.accept || request.accept == "*/*"
        render plain: "#{params[:race][:name]}", status: :ok
      else
        @race = Race.new(race_params);
        if @race.save
          render plain: race_params[:name], status: :created
        else
          render json: @race.errors
        end
      end
    end

    def update
      @race = Race.find(params[:id])
      if @race.update(race_params)
        render json: @race, status: :ok
      else
        render json: @race.errors
      end
    end

    def destroy
      @race = Race.find(params[:id])
      @race.destroy
      render nothing: true, status: :no_content
    end

    private

    def set_race

    end

    def race_params
      params.require(:race).permit(:name, :date)
    end
  end
end