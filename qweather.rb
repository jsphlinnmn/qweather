require 'uri'
require 'net/http'
require 'json'
require 'openssl'
require 'date'
require 'optparse'

def get_data(url)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri)
  response = http.request(request)
  JSON.parse(response.read_body)
end


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby qweather.rb [options]"

  opts.on('-u', '--usage', 'Display this usage message') do
    puts opts
    exit
  end

  opts.on('-v', '--verbose', 'Verbose response (default is less output)') do
    options[:verbose] = true
  end
end.parse!




while true do
  puts "---------------------------------"
  puts "Enter the zip code to search for: "
  zip = STDIN.gets.chomp


  puts "View forecast for how many days, including today?"
  days = STDIN.gets.chomp

  today_d = Date.today
  end_d = Date.new(today_d.year, today_d.month, today_d.day + days.to_i - 1)

  url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{zip}/#{today_d}/#{end_d}?key=EJLXDL3V6TAFFTUXCC8EUVKAS"

  begin
    results = get_data(url)
  rescue JSON::ParserError
    puts "Error: Invalid zip code. Please try again."
    next
  end



  results["days"].each do |day|

    puts "---------------------------------"
    puts "Date: #{day["datetime"]}"
    puts "Conditions: #{day["conditions"]}"
    puts "Max Temp: #{day["tempmax"]}"
    puts "Min Temp: #{day["tempmin"]}"
    puts "Precipitation: #{day["precip"]}"
    puts "Windspeed: #{day["windspeed"]}"
    puts "Visibility: #{day["visibility"]}"
    if (options[:verbose])
      puts "Sunrise: #{day["sunrise"]}"
      puts "Sunset: #{day["sunset"]}"
      puts "Moonrise: #{day["moonrise"]}"
      puts "Moonset: #{day["moonset"]}"
      puts "Moonphase: #{day["moonphase"]}"
    end
    puts "---------------------------------"
  end
end
