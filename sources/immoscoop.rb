require 'httparty'
require 'nokogiri'
require 'json'

class ImmoScoopScraper
  BASE_URL = 'https://www.immoscoop.be'
  
  def self.fetch_houses
    @url = "https://www.immoscoop.be/zoeken/te-koop/merelbeke/woonhuis?minBedrooms=2&minPrice=350000&maxPrice=800000&page=1&sort=scoop%2CDESC%7Cdate%2CDESC"
    response = HTTParty.get(@url)
    return [] unless response.success?

    doc = Nokogiri::HTML(response.body)
    parse_listings(doc)
  end

  private

  def self.parse_listings(doc)
    listings = []
    
    # Look for property cards using the data-mobile-selector attribute
    doc.css('a[data-mobile-selector="property-card_card"]').each do |card|
      property = extract_property_data(card)
      listings << property if property
    end

    listings
  end

  def self.extract_property_data(card)
    # Get the content div that contains all property information
    content = card.css('.property-card_content__hR3ZF').first
    return nil unless content

    # Extract the URL from the card's href attribute
    url = card['href']
    full_url = url ? (url.start_with?('http') ? url : BASE_URL + url) : nil

    # Get the office logo/name if available
    office_logo = card.css('.agent-logo_logo___rDZa').first
    office_name = office_logo&.attr('src')

    # Get the first image URL if available
    first_image = card.css('.image-gallery-image').first
    image_url = first_image&.attr('src')

    # Extract all the basic information
    price_element = content.css('.property-card_price__XfyPH').first
    address_element = content.css('address div').first
    specs_element = content.css('.FeatureIcons_wrapper__qWm9o').first

    # Extract price (remove non-numeric characters except decimal point)
    price_text = price_element&.text&.strip
    price = price_text ? price_text.gsub(/[^0-9.]/, '').to_i : nil

    # Extract address components
    street = address_element&.css('div')&.first&.text&.strip
    city = address_element&.css('div')&.last&.text&.strip

    # Extract EPC rating
    epc = extract_epc(content)

    # Build the complete property hash
    {
      price: price,
      raw_price: price_text,
      street: street,
      city: city,
      full_address: [street, city].compact.join(', '),
      epc: epc,
      surface: extract_surface(specs_element),
      terrain: extract_terrain(specs_element),
      bedrooms: extract_bedrooms(specs_element),
      bathrooms: extract_bathrooms(specs_element),
      has_parking: extract_parking(specs_element),
      url: full_url,
      image_url: image_url,
      office_name: office_name
    }.compact
  end

  def self.extract_epc(content)
    # Find the SVG title element which contains the EPC rating
    svg = content.css('svg').first
    svg&.css('title')&.text
  end

  def self.extract_surface(specs_element)
    return nil unless specs_element
    
    surface_item = specs_element.css('.FeatureIcons_item__9M7v0').find do |item|
      item.css('[data-name="livable-surface-area"]').any?
    end
    
    surface_item&.css('.FeatureIcons_value__flPF6')&.text&.to_i
  end

  def self.extract_terrain(specs_element)
    return nil unless specs_element
    
    terrain_item = specs_element.css('.FeatureIcons_item__9M7v0').find do |item|
      item.css('[data-name="terrain-area"]').any?
    end
    
    terrain_item&.css('.FeatureIcons_value__flPF6')&.text&.gsub('.', '')&.to_i
  end

  def self.extract_bedrooms(specs_element)
    return nil unless specs_element
    
    bedrooms_item = specs_element.css('.FeatureIcons_item__9M7v0').find do |item|
      item.css('[data-name="bedrooms"]').any?
    end
    
    bedrooms_item&.css('.FeatureIcons_value__flPF6')&.text&.to_i
  end

  def self.extract_bathrooms(specs_element)
    return nil unless specs_element
    
    bathrooms_item = specs_element.css('.FeatureIcons_item__9M7v0').find do |item|
      item.css('[data-name="bathrooms"]').any?
    end
    
    bathrooms_item&.css('.FeatureIcons_value__flPF6')&.text&.to_i
  end

  def self.extract_parking(specs_element)
    return nil unless specs_element
    
    specs_element.css('.FeatureIcons_item__9M7v0').any? do |item|
      item.css('[data-name="parking"]').any?
    end
  end
end
