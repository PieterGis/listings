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

  # puts "Fetching houses from Axel Lenaerts..."
  # axellenaerts_houses = AxelLenaertsScraper.fetch_houses.map do |house|
  #   puts house
  #   {
  #     title: house[:title],
  #     price: house[:price],
  #     location: house[:location],
  #     type: "House",
  #     bedrooms: house[:bedrooms],
  #     url: house[:url],
  #     image_url: house[:image_url],
  #     source: 'Axel Lenaerts'
  #   }
  # end
  # houses += axellenaerts_houses

  puts "Fetching houses from Devos Vastgoed..."
  devosvastgoed_houses = DevosVastgoedScraper.fetch_houses.map do |house|
    puts house
    {
      id: house[:id],
      title: house[:title],
      price: house[:price],
      location: house[:location],
      type: "House",
      bedrooms: house[:bedrooms],
      url: house[:url],
      image_url: house[:image_url],
      source: 'Devos Vastgoed'
    }
  end 
  puts devosvastgoed_houses
  houses += devosvastgoed_houses

  houses
end


