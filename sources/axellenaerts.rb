require 'nokogiri'
require 'httparty'
require 'json'

class AxelLenaertsScraper
  BASE_URL = 'https://www.axellenaerts.be'
  
  def self.fetch_houses(params = {})
    url = "#{BASE_URL}/nl/kopen"
    
    default_params = {
      pg: 1,
      mapsView: false,
      state: 56,
      type: 491,
      order: 'postdate_desc',
      regions: '',
      zips: '9820',
      bedrooms: 2,
      minbudget: 350000,
      maxbudget: 1000000
    }
    
    query_params = default_params.merge(params)
    
    begin
      headers = {
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'nl-BE,nl;q=0.9,en-US;q=0.8,en;q=0.7',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache'
      }
      
      response = HTTParty.get(url, query: query_params, headers: headers)
      
      if response.success?
        doc = Nokogiri::HTML(response.body)
        houses = []
        
        # Try different possible selectors for property listings
        property_elements = doc.css('.estate-grid .estate-item, .property-list .property-item, article.property')
        
        property_elements.each do |property|
          begin
            # Extract data with multiple possible selectors
            title = property.css('h2, .property-title, .estate-title').text.strip
            price = property.css('.price, .property-price, .estate-price').text.strip
            location = property.css('.location, .property-location, .estate-location').text.strip
            
            # Try to find the link - multiple possible patterns
            link_element = property.css('a').find { |a| a['href']&.include?('/nl/kopen/') }
            url = link_element ? (BASE_URL + link_element['href']) : nil
            
            # Try to find the image - multiple possible patterns
            image_element = property.css('img').first
            image_url = image_element ? image_element['src'] || image_element['data-src'] : nil
            
            # Extract additional details if available
            details = {
              bedrooms: property.css('.bedrooms, .rooms').text.strip,
              surface: property.css('.surface, .area').text.strip,
              epc: property.css('.epc').text.strip
            }
            
            house_data = {
              title: title,
              price: price,
              location: location,
              url: url,
              image_url: image_url,
              details: details
            }.compact # Remove nil values
            
            houses << house_data if house_data[:title].to_s.length > 0
          rescue => e
            puts "Error parsing property: #{e.message}"
            next
          end
        end
        
        result = {
          success: true,
          total_results: houses.length,
          data: houses
        }
        
        # Debug information
        puts "\nFound #{houses.length} properties"
        puts "Sample property:" if houses.any?
        puts JSON.pretty_generate(houses.first) if houses.any?
        
        return result
      else
        return {
          success: false,
          error: "HTTP request failed with status #{response.code}"
        }
      end
      
    rescue StandardError => e
      return {
        success: false,
        error: e.message
      }
    end
  end
end
