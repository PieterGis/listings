require 'launchy'

class WebpageGenerator
  def self.generate_html(houses)
    # Group houses by source
    houses_by_source = houses.group_by { |house| house[:source] }
    
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>House Listings</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
          }
          .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            max-width: 1200px;
            margin: 0 auto 20px;
          }
          .tab {
            padding: 10px 20px;
            background-color: #e2e8f0;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1em;
            transition: background-color 0.2s;
          }
          .tab.active {
            background-color: #2c5282;
            color: white;
          }
          .tab:hover {
            background-color: #cbd5e0;
          }
          .tab.active:hover {
            background-color: #2c5282;
          }
          .tab-content {
            display: none;
          }
          .tab-content.active {
            display: block;
          }
          .house-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            max-width: 1200px;
            margin: 0 auto;
          }
          .house-card {
            background: white;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
            position: relative;
          }
          .house-card:hover {
            transform: translateY(-5px);
          }
          .house-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 4px;
          }
          .price {
            font-size: 1.2em;
            font-weight: bold;
            color: #2c5282;
            margin: 10px 0;
          }
          .location {
            color: #666;
            font-size: 0.9em;
          }
          .details {
            margin-top: 10px;
          }
          .view-button {
            display: inline-block;
            background-color: #2c5282;
            color: white;
            padding: 8px 16px;
            border-radius: 4px;
            text-decoration: none;
            margin-top: 10px;
          }
          .view-button:hover {
            background-color: #1a365d;
          }
          h3 {
            margin: 10px 0;
            color: #333;
          }
          .source-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 4px 8px;
            border-radius: 4px;
            color: white;
            font-size: 0.8em;
            font-weight: bold;
          }
          .source-bordes {
            background-color: #2c5282;
          }
          .source-immoweb {
            background-color: #e53e3e;
          }
        </style>
        <script>
          function openSource(evt, sourceName) {
            var i, tabcontent, tablinks;
            
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
              tabcontent[i].style.display = "none";
            }
            
            tablinks = document.getElementsByClassName("tab");
            for (i = 0; i < tablinks.length; i++) {
              tablinks[i].className = tablinks[i].className.replace(" active", "");
            }
            
            document.getElementById(sourceName).style.display = "block";
            evt.currentTarget.className += " active";
          }

          // Open first tab by default when page loads
          window.onload = function() {
            document.getElementsByClassName("tab")[0].click();
          }
        </script>
      </head>
      <body>
        <div class="tabs">
          #{houses_by_source.keys.map { |source| 
            %(<button class="tab" onclick="openSource(event, '#{source}')">#{source}</button>)
          }.join("\n")}
        </div>

        #{houses_by_source.map { |source, source_houses|
          <<~TAB_CONTENT
            <div id="#{source}" class="tab-content">
              <div class="house-grid">
                #{source_houses.map { |house| generate_house_card(house) }.join("\n")}
              </div>
            </div>
          TAB_CONTENT
        }.join("\n")}
      </body>
      </html>
    HTML

    # Write HTML to temporary file
    File.write('houses.html', html)
    
    # Return the file path
    File.expand_path('houses.html')
  end

  private

  def self.generate_house_card(house)
    source_class = "source-#{house[:source].downcase}"
    <<~HTML
      <div class="house-card">
        <div class="source-badge #{source_class}">#{house[:source]}</div>
        <img src="#{house[:image_url]}" alt="#{house[:title]}" class="house-image">
        <h3>#{house[:title]}</h3>
        <p class="price">€#{format_price(house[:price])}</p>
        <p class="location">#{house[:location]}</p>
        <div class="details">
          <p>#{house[:bedrooms]} bedrooms • #{house[:type]}</p>
        </div>
        <a href="#{house[:url]}" class="view-button" target="_blank">View Details</a>
      </div>
    HTML
  end

  def self.format_price(price)
    price.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1.')
  end

  def self.open_in_browser(file_path)
    Launchy.open(file_path)
  end
end 