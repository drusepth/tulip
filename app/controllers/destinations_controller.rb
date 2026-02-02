# frozen_string_literal: true

class DestinationsController < ApplicationController
  def index
    @destinations = FeaturedDestination.all
  end
end
