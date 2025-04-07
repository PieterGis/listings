require 'httparty'
require 'nokogiri'
require 'json'

class BordesScraper
  API_URL = 'https://www.bordes.be/api/properties.json'
  
  def self.fetch_houses
    params = {
      order: 'available_first',
      state: '14,16',
      projects: false,
      zip: '9820,9820,9820,9820,9070,9770,9090',
      near: '',
      radius: 10,
      exclude: '',
      soldBy: '',
      type: 3408
    }

    headers = {
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept' => 'application/json',
      'Accept-Language' => 'en-US,en;q=0.5'
    }
    
    response = HTTParty.get(API_URL, query: params, headers: headers)
    
    if response.code != 200
      puts "Error: Failed to fetch the page (HTTP #{response.code})"
      return []
    end

    properties = []

    begin
      data = JSON.parse(response.body)
      data['data'].each do |property|
        properties << {
          id: property['id'],
          title: property['title'],
          price: property['features']['price']['value'],
          image_url: property['srcset'].split(' ').first,
          location: "#{property['address']['street1']}, #{property['address']['zip']} #{property['address']['city']}",
          type: property['type'].first['title'],
          bedrooms: property['features']['primary']['value'],
          url: property['url']
        }
      end

      properties
    rescue JSON::ParserError => e
      puts "Error parsing JSON response: #{e.message}"
      return []
    end
  end
end
