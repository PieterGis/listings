require 'nokogiri'
require 'httparty'
require 'json'

class ImmoZoneScraper
  BASE_URL = 'https://immo-zone.be'
  
  def self.fetch_houses(min_price = 350000, max_price = 800000)
    url = "#{BASE_URL}/kopen/alle/huis/#{min_price}/#{max_price}"
    response = HTTParty.get(url)
    if response.code == 200
      parse_listings(response.body)
    else
      puts "Error fetching data: #{response.code}"
      []
    end
  end
  
  private
  
  def self.parse_listings(html)
    doc = Nokogiri::HTML(html)
    listings = []
    
    doc.css('.pubholder').each do |item|
        next unless (extract_status(item) != "Verkocht")

        listing = {
        price: extract_price(item),
        type: extract_type(item),
        location: extract_location(item),
        title: extract_title(item),
        features: extract_features(item),
        image_url: extract_image_url(item),
        url: extract_url(item),
        status: extract_status(item)
        }
        
        listings << listing unless listing[:price].nil?
    end
    listings
  end
  
  def self.extract_price(item)
    price_text = item.css('.price').text.strip
    if price_text == "Verkocht"
      "Verkocht"
    else
      price_text.gsub(/[^0-9]/, '').to_i
    end
  end
  
  def self.extract_type(item)
    item.css('.type').text.strip
  end
  
  def self.extract_location(item)
    location = item.css('.location b').text.strip
    item.css('.location').text.gsub('|', '').strip
  end
  
  def self.extract_title(item)
    item.css('.title').text.strip
  end
  
  def self.extract_features(item)
    features = {}
    
    item.css('.specs li').each do |feature|
      text = feature.text.strip
      
      case text
      when /(\d+)\s*m²/, /(\d+)m2/
        features[:living_area] = $1.to_i
      when /(\d+)\s*slpk/i, /(\d+)\s*slaapkamers/i, /Slpk\.\s*(\d+)/i
        features[:bedrooms] = $1.to_i
      when /(\d+)\s*badk/i, /(\d+)\s*badkamers/i, /Badk\.\s*(\d+)/i
        features[:bathrooms] = $1.to_i
      when /(\d+)\s*m²\s*grond/i, /(\d+)\s*m²\s*terrein/i
        features[:plot_area] = $1.to_i
      end
    end
    
    features
  end
  
  def self.extract_status(item)
    status = item.css('.publabel').text.strip
    status || "Available"
  end
  
  def self.extract_url(item)
    href = item.css('.overlay').first&.attr('href')
    href ? BASE_URL + href : nil
  end
  
  def self.extract_image_url(item)
    style = item.css('.pub').first&.attr('style')
    if style && style =~ /url\('([^']+)'\)/
      $1
    else
      nil
    end
  end
end