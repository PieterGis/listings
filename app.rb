require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require_relative 'script'  # your existing scraper script

class HouseScraper < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  # Serve static files from public directory
  set :public_folder, File.dirname(__FILE__) + '/public'

  # Helper method to get available sources
  def available_sources
    # Extract source names from the files in sources directory
    Dir[File.join(__dir__, 'sources', '*.rb')]
      .map { |f| File.basename(f, '.rb') }
  end

  get '/' do
    @available_sources = available_sources
    @selected_sources = params['sources']

    # Get houses from your existing script with source filtering
    @houses = if @selected_sources && !@selected_sources.empty?
      fetch_and_show_houses.select { |house| @selected_sources.include?(house[:source].downcase) }
    else
      @selected_sources = @available_sources # Select all by default
      fetch_and_show_houses
    end

    erb :index
  end

  # Add an API endpoint if needed
  get '/api/houses' do
    content_type :json
    selected_sources = params['sources']&.split(',')

    houses = if selected_sources && !selected_sources.empty?
      fetch_and_show_houses.select { |house| selected_sources.include?(house[:source].downcase) }
    else
      fetch_and_show_houses
    end

    houses.to_json
  end
end 