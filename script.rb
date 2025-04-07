require 'dotenv'
require 'json'
require 'digest'
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

PREVIOUS_RESULTS_FILE = 'previous_results.json'
SCRAPERS = {
  'Bordes' => BordesScraper,
  'Immoweb' => ImmowebScraper,
  'ImmoZone' => ImmoZoneScraper,
  'ImmoScoop' => ImmoScoopScraper,
  'Casteels Vastgoed' => CasteelsVastgoedScraper,
  'Zimmo' => ZimmoScraper,
  'Axel Lenaerts' => AxelLenaertsScraper,
  'Devos Vastgoed' => DevosVastgoedScraper
}

def load_previous_results
  return [] unless File.exist?(PREVIOUS_RESULTS_FILE)
  JSON.parse(File.read(PREVIOUS_RESULTS_FILE), symbolize_names: true)
rescue JSON::ParserError
  []
end

def save_results(houses)
  File.write(PREVIOUS_RESULTS_FILE, JSON.pretty_generate(houses))
end

def find_new_houses(current_houses, previous_houses)
  current_ids = current_houses.map { |h| h[:id] }.to_set
  previous_ids = previous_houses.map { |h| h[:id] }.to_set
  current_houses.select { |h| !previous_ids.include?(h[:id]) }
end

def fetch_and_show_houses
  sources = SCRAPERS.map do |name, scraper_class|
    {
      name: name,
      scraper: -> { scraper_class.fetch_houses.map { |h| standardize_house(h, name) } }
    }
  end

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
  current_houses = threads.map(&:join).map(&:value).flatten
  
  # Load previous results and find new houses
  previous_houses = load_previous_results
  new_houses = find_new_houses(current_houses, previous_houses)
  
  # Mark new houses in the results
  current_houses.each do |house|
    house[:is_new] = new_houses.any? { |h| h[:id] == house[:id] }
  end
  
  # Sort houses to put new ones at the top
  current_houses.sort_by! { |house| house[:is_new] ? 0 : 1 }
  
  # Save current results for next time
  save_results(current_houses)
  
  current_houses
end

private

def standardize_house(house, source)
  unique_id = generate_unique_id(house, source)
  {
    id: unique_id,
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

def generate_unique_id(house, source)
  # Adjust which components to use based on what's available
  components = [
    source,
    house[:url],
    house[:location],
    house[:price]&.to_s,
    house[:title],        # Add title for more uniqueness
    house[:bedrooms]&.to_s # Add bedrooms for more uniqueness
  ].compact.join('|')
  
  Digest::SHA256.hexdigest(components)[0..15]
end


