require 'dotenv'
require_relative 'sources/immoweb'
require_relative 'sources/bordes'
require_relative 'sources/immo_zone'
require_relative 'sources/immoscoop'
require_relative 'sources/casteelsvastgoed'
require_relative 'sources/zimmo'
require_relative 'sources/devosvastgoed'
require_relative 'sources/axellenaerts'

# Load environment variables from .env file
Dotenv.load

def fetch_and_show_houses
  sources = [
    { name: 'Bordes', scraper: -> { BordesScraper.fetch_houses.map { |h| standardize_house(h, 'Bordes') } } },
    { name: 'Immoweb', scraper: -> { ImmowebScraper.fetch_houses.map { |h| standardize_house(h, 'Immoweb') } } },
    { name: 'ImmoZone', scraper: -> { ImmoZoneScraper.fetch_houses.map { |h| standardize_house(h, 'ImmoZone') } } },
    { name: 'ImmoScoop', scraper: -> { ImmoScoopScraper.fetch_houses.map { |h| standardize_house(h, 'ImmoScoop') } } },
    { name: 'Casteels Vastgoed', scraper: -> { CasteelsVastgoedScraper.fetch_houses.map { |h| standardize_house(h, 'Casteels Vastgoed') } } },
    { name: 'Zimmo', scraper: -> { ZimmoScraper.fetch_houses.map { |h| standardize_house(h, 'Zimmo') } } },
    { name: 'Axel Lenaerts', scraper: -> { AxelLenaertsScraper.fetch_houses.map { |h| standardize_house(h, 'Axel Lenaerts') } } },
    { name: 'Devos Vastgoed', scraper: -> { DevosVastgoedScraper.fetch_houses.map { |h| standardize_house(h, 'Devos Vastgoed') } } }
  ]

  # Process sources in parallel using threads
  threads = sources.map do |source|
    Thread.new do
      begin
        puts "Fetching houses from #{source[:name]}..."
        source[:scraper].call
      rescue StandardError => e
        puts "Error fetching from #{source[:name]}: #{e.message}"
        []
      end
    end
  end

  # Wait for all threads to complete and collect results
  threads.map(&:join).map(&:value).flatten
end

private

def standardize_house(house, source)
  {
    id: house[:id],
    title: house[:title],
    price: house[:price].is_a?(String) ? house[:price].to_i : house[:price],
    image_url: house[:image_url],
    location: house[:location],
    type: "House",
    bedrooms: house[:bedrooms],
    url: house[:url],
    source: source
  }
end


