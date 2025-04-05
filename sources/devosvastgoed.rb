require 'nokogiri'
require 'httparty'
require 'uri'

class DevosVastgoedScraper
  BASE_URL = 'https://www.vastgoeddevos.be'
  
  def self.fetch_houses()
    url = "#{BASE_URL}/te-koop?category=14&city%5B%5D=gent&city%5B%5D=gentbrugge&city%5B%5D=sint-amandsberg&priceRange=&status=te+koop"
    
    response = HTTParty.get(url)
    return [] unless response.success?

    doc = Nokogiri::HTML(response.body)
    listings = []

    # Find all property listings - they are in div.col-xs-12.col-sm-6.col-md-6.col-lg-4.item.gall-heights
    doc.css('div.col-xs-12.col-sm-6.col-md-6.col-lg-4.item.gall-heights').each do |item|
      # Extract the reference from the id attribute (estate-XXXXX)
      reference = item['id']&.sub('estate-', '')
      
      # Extract price from the div.price element
      price_text = item.css('div.price').text.strip
      
      # Extract location details
      street = item.css('div.street p').text.strip
      city = item.css('div.street h2').text.strip
      
      # Extract bedroom count and area from the icons
      icons = item.css('div.icon-item')
      bedrooms = icons.find { |i| i.css('img[alt="bedroom icon"]').any? }&.css('span')&.text&.to_i
      area = icons.find { |i| i.css('img[alt="ground area icon"]').any? }&.css('span')&.text&.gsub(/[^\d]/, '')&.to_i

      # Extract status (if property is "in optie")
      status = item.css('div.banner')&.text&.strip

      # Extract the URL
      url = item.css('a.estate-picture').first['href']
      full_url = url.start_with?('/') ? "#{BASE_URL}#{url}" : url

      # Extract image URL
      image_url = item.css('a.estate-picture img').first['src']
      full_image_url = image_url.start_with?('/') ? "#{BASE_URL}#{image_url}" : image_url

      listing = {
        reference: reference,
        price: extract_price(price_text),
        address: street,
        city: city,
        bedrooms: bedrooms,
        area: area,
        status: status,
        url: full_url,
        image_url: full_image_url
      }
      
      listings << listing
    end
    
    listings
  end

  private

  def self.extract_price(price_text)
    return nil if price_text.nil? || price_text.empty?
    # Extract numbers from strings like "€439.000,-"
    price_text.gsub(/[^\d]/, '').to_i
  end
end
