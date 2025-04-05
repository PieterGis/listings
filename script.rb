require 'mail'
require 'dotenv'
require_relative 'mail'
require_relative 'immoweb'
require_relative 'bordes'
require_relative 'webpage'
require_relative 'immo_zone'
require_relative 'immoscoop'
require_relative 'casteelsvastgoed'
require_relative 'zimmo'

# Load environment variables from .env file
Dotenv.load

def fetch_and_show_houses
  houses = []

  # Get houses from Bordes
  puts "Fetching houses from Bordes..."
  bordes_scraper = BordesScraper.new
  bordes_houses = bordes_scraper.scrape_all_listings.map do |house|
    house.merge(source: 'Bordes')
  end
  houses += bordes_houses
  
  # Get houses from Immoweb
  puts "Fetching houses from Immoweb..."
  immoweb_houses = ImmowebScraper.fetch_houses.map do |house|
    {
      id: house[:id],
      title: house[:title],
      price: house[:price].to_i,
      image_url: house[:image_url],
      location: house[:location],
      type: "House",
      bedrooms: house[:bedrooms],
      url: house[:url],
      source: 'Immoweb'
    }
  end
  houses += immoweb_houses

  puts "Fetching houses from ImmoZone..."
  immozone_houses = ImmoZoneScraper.fetch_houses.map do |house|
    {
      id: house[:id],
      title: house[:title],
      price: house[:price].to_i,
      image_url: house[:image_url],
      location: house[:location],
      type: "House",
      bedrooms: house[:bedrooms],
      url: house[:url],
      source: 'ImmoZone'
    }
  end
  houses += immozone_houses

  puts "Fetching houses from ImmoScoop..."
  immoscoop_houses = ImmoScoopScraper.fetch_houses.map do |house|
    {
      id: house[:id],
      title: house[:title],
      price: house[:price].to_i,  
      image_url: house[:image_url], 
      location: house[:location],
      type: "House",
      bedrooms: house[:bedrooms],
      url: house[:url],
      source: 'ImmoScoop'
    }
  end
  houses += immoscoop_houses
  
  puts "Fetching houses from Casteels Vastgoed..."
  casteels_houses = CasteelsVastgoedScraper.fetch_houses.map do |house|
    {
      id: house[:id],
      title: house[:title],
      price: house[:price].to_i, 
      location: house[:location],
      type: "House",
      bedrooms: house[:bedrooms],
      url: house[:url],
      image_url: house[:image_url],
      source: 'Casteels Vastgoed'
    }
  end
  houses += casteels_houses

  puts "Fetching houses from Zimmo..."
  zimmo_houses = ZimmoScraper.fetch_houses.map do |house|
    {
      id: house[:id],
      title: house[:title],
      price: house[:price],
      image_url: house[:image_url],
      location: house[:location],
      type: "House",
      bedrooms: house[:bedrooms],
      url: house[:url],
      source: 'Zimmo'
    }
  end
  houses += zimmo_houses

  # Generate HTML and open in browser
  html_file_path = WebpageGenerator.generate_html(houses)
  WebpageGenerator.open_in_browser(html_file_path)
end

# Run the script
fetch_and_show_houses

