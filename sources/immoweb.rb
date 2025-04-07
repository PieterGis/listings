require 'httparty'
require 'nokogiri'
require 'json'

class ImmowebScraper
  def self.fetch_houses
    houses = []
    
    url = "https://www.immoweb.be/nl/zoeken/huis/te-koop/merelbeke/9820"
    params = {
      countries: 'BE',
      minPrice: 350000,
      maxPrice: 800000,
      page: 1,
      orderBy: 'relevance'
    }
    
    response = HTTParty.get(url, query: params)
    doc = Nokogiri::HTML(response.body)
    
    # Extract property cards
    properties = doc.css('.card--result')
    
    properties.each do |property|
      begin
        # Extract background image from the media container
        media_container = property.css('.card__media-container').first
        background_div = media_container&.css('.card__media-background')&.first
        image_url = background_div['style'][/url\((.*?)\)/, 1] if background_div && background_div['style']
        
        # Extract title and URL from the title link
        title_link = property.css('.card__title-link').first
        title = title_link&.text&.strip
        property_url = title_link&.attr('href')
        
        # Extract address
        address = property.css('.card--results__information--locality')&.text&.strip
        
        # Extract price from iw-price element
        price_element = property.css('iw-price').first
        if price_element && price_element[':price']
          price_data = JSON.parse(price_element[':price'])
          price = price_data['mainValue']
        end
        
        # Only add if we have at least some data
        if title || price || image_url
          houses << {
            title: title,
            price: price,
            image_url: image_url,
            location: address,
            type: 'House',
            bedrooms: 2,
            url: property_url
          }
        end
      rescue => e
        puts "Error processing property: #{e.message}"
      end
    end
    
    houses
  end
end
