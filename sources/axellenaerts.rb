require 'httparty'
require 'json'

class AxelLenaertsScraper
  BASE_URL = 'https://www.axellenaerts.be'
  API_URL = "#{BASE_URL}/api/properties.json"
  
  def self.fetch_houses(params = {})
    default_params = {
      pg: 1,
      mapsView: false,
      state: 56,
      order: 'postdate_desc',
      regions: 'gent-de-pinte',
      zips: ''
    }
    
    query_params = default_params.merge(params)
    
    begin
      headers = {
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept' => 'application/json',
        'Referer' => 'https://www.axellenaerts.be/'
      }
      
      response = HTTParty.get(API_URL, query: query_params, headers: headers)
      
      if response.success?
        json_response = JSON.parse(response.body)
        properties = json_response['data']
        
        houses = properties.map do |property|
          {
            id: property['id'],
            title: "#{property['type']} - #{property['city']}",
            price: property['price'],
            location: property['city'],
            url: property['url'],
            image_url: BASE_URL + property['srcset']&.split(' ')&.first,
            type: property['type'],
            label: property['label'],
            coordinates: property['coords'],
            details: {
              state: property['states']&.first&.dig('title'),
              recently_updated: property['recently_updated'],
              date: property['date']
            }
          }.compact
        end
      end
    end
  end
end
