require 'mail'
require 'dotenv'

# Load environment variables
Dotenv.load

options = { 
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'gmail.com',
  user_name:            ENV['GMAIL_USERNAME'],
  password:             ENV['GMAIL_PASSWORD'],
  authentication:       'plain',
  enable_starttls_auto: true  
}

# Debug output
puts "Mail options:"
puts "  user_name: #{options[:user_name]}"
puts "  password: #{options[:password] ? '***' : 'nil'}"

Mail.defaults { delivery_method :smtp, options }

def send_email(houses)
  return if houses.empty?

  body = houses.map do |house|
    <<~HTML
      <div style="margin-bottom: 20px; padding: 10px; border: 1px solid #ddd;">
        <h3>#{house[:title]}</h3>
        <p><strong>Price:</strong> #{house[:price]}</p>
        #{house[:image_url] ? "<img src='#{house[:image_url]}' style='max-width: 300px;' />" : ""}
      </div>
    HTML
  end.join("\n")

  html_body = <<~HTML
    <html>
      <body>
        <h2>New Houses Found (#{houses.size})</h2>
        #{body}
      </body>
    </html>
  HTML

  puts html_body

#   mail = Mail.new do
#     from    ENV['GMAIL_USERNAME']
#     to      ENV['GMAIL_USERNAME']
#     subject "New Houses Found (#{houses.size})"
#     html_part do
#       content_type 'text/html; charset=UTF-8'
#       body html_body
#     end
#   end

#   mail.deliver!
end