require 'selenium-webdriver'
require 'nokogiri'
require 'json'

class ZimmoScraper
  def self.fetch_houses
    return []
    houses = []
    
    # Enhanced Chrome options to appear more like a real browser
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36')
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--no-sandbox')
    
    # Add required preferences
    options.add_preference('intl.accept_languages', 'nl-BE,nl')
    
    driver = Selenium::WebDriver.for :chrome, options: options
    
    begin
      # Set document.webdriver to false to avoid detection
      driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
      
      url = "https://www.zimmo.be/nl/zoeken/"
      params = {
        search: "eyJmaWx0ZXIiOnsic3RhdHVzIjp7ImluIjpbIkZPUl9TQUxFIiwiVEFLRV9PVkVSIl19LCJwbGFjZUlkIjp7ImluIjpbMTI5LDE1MDYsMTUwNywxNTA4LDE1MDksMTUxMCwxNTExLDE1MTIsMTUxMywxNTE0LDE1MTUsMTUxNiwxNTE3LDE1MTgsMTUxOSwyNTgsMzMyOCwzMzM0LDUwOSw1NjMsOTldfSwiY2F0ZWdvcnkiOnsiaW4iOlsiSE9VU0UiXX0sInByaWNlIjp7InVua25vd24iOnRydWUsInJhbmdlIjp7Im1pbiI6MzUwMDAwLCJtYXgiOjgwMDAwMH19LCJiZWRyb29tcyI6eyJ1bmtub3duIjp0cnVlLCJyYW5nZSI6eyJtaW4iOjJ9fX19"
      }
      full_url = "#{url}?search=#{params[:search]}"
      
      # Add random delay before loading page
      sleep rand(2..4)
      
      driver.get(full_url)
      
      # Wait for specific elements rather than fixed sleep
      wait = Selenium::WebDriver::Wait.new(timeout: 15)
      wait.until { driver.find_elements(css: '.property-card, .property-item, .property, [data-component="property-card"]').size > 0 }
      
      # Scroll the page to simulate human behavior
      driver.execute_script("window.scrollTo(0, document.body.scrollHeight/2)")
      sleep rand(1..2)
      
      doc = Nokogiri::HTML(driver.page_source)
      
      properties = doc.css('.property-card, .property-item, .property, [data-component="property-card"]')
      
      puts "Found #{properties.length} properties"
      
      properties.each do |property|
        begin
          image_url = property.css('img[src*="zimmo"], img[data-src*="zimmo"]').first&.[]('src') ||
                     property.css('img[src*="zimmo"], img[data-src*="zimmo"]').first&.[]('data-src')
          
          title = property.css('.property-item_title')&.text&.strip
          
          price_text = property.css('.price, [class*="price"]')&.text&.strip
          price = price_text&.scan(/[0-9.,]+/)&.first&.gsub(/[.,]/, '')&.to_i if price_text
          
          if title || price || image_url
            house = {
              title: title,
              price: price,
              image_url: image_url
            }
            houses << house
          end
        rescue => e
          puts "Error processing property: #{e.message}"
        end
      end
      
    ensure
      driver.quit
    end
    
    houses
  end
end