require 'httparty'
require 'nokogiri'
require 'json'

class CasteelsVastgoedScraper
  BASE_URL = "https://casteelsvastgoed.be/huis-kopen/ons-aanbod/"

  def self.fetch_houses
    houses = []
    
    params = {
      'purchase[0]' => '114',
      'type[0]' => '116',
      'location[0]' => '214',
      'location[1]' => '115',
      'location[2]' => '156',
      'location[3]' => '286',
      'location[4]' => '140',
      'location[5]' => '128',
      'pricemin[0]' => '100000',
      'pricemax[0]' => '100000000',
      'sort' => 'available'
    }
    
    response = HTTParty.get(BASE_URL, query: params)
    doc = Nokogiri::HTML(response.body)
    
    # The website shows property listings in colEstates divs
    properties = doc.css('.colEstates')

    properties.each do |property|
      begin
        # Get the property link which contains all the information
        property_link = property.css('a').first
        next unless property_link

        status = property_link.css('.label p')&.text&.strip
        next unless status != 'Verkocht'

        # Extract property details
        title = property_link.css('h3')&.text&.strip
        info = property_link.css('.info')&.text&.strip
        
        # Extract price if available (some properties are marked as "Verkocht")
        price_element = property_link.css('.price')
        price = if price_element&.text&.include?('€')
          price_element.text.gsub(/[^0-9]/, '').to_i
        end
        
        # Extract image URL from the background style
        img_div = property_link.css('.img').first
        image_url = if img_div && img_div['style']
          style = img_div['style']
          matches = style.match(/url\('([^']+)'\)/)
          matches[1] if matches
        end
        
        # Extract icons information (surface area, living area, bedrooms)
        icons = property_link.css('.icons .icon')
        ground_surface = icons.find { |icon| icon.css('img').attr('alt')&.text&.include?('grondoppervlakte') }&.css('p')&.text&.strip
        living_surface = icons.find { |icon| icon.css('img').attr('alt')&.text&.include?('woonoppervlakte') }&.css('p')&.text&.strip
        bedrooms = icons.find { |icon| icon.css('img').attr('alt')&.text&.include?('Slaapkamers') }&.css('p')&.text&.to_i
        
        # Extract status (sold, available, etc)

        
        # Extract location from title (format is usually "Verkocht in Location" or similar)
        location = title.split(' in ').last if title

        # Only add if we have at least some basic data
        if title || price
          houses << {
            title: title,
            info: info,
            price: price,
            location: location,
            image_url: image_url,
            ground_surface: ground_surface,
            living_surface: living_surface,
            bedrooms: bedrooms,
            status: status,
            url: property_link['href']
          }
        end
      rescue => e
        puts "Error processing property: #{e.message}"
      end
    end
    
    houses
  end
end