require 'net/http'
require 'xmlsimple'

# Get a WOEID (Where On Earth ID)
# for your location from here:
# http://woeid.rosselliot.co.nz/
woeid = 12034

# Temerature format:
# 'c' for Celcius
# 'f' for Fahrenheit
format = 'c'

query  = URI::encode "select * from weather.forecast WHERE woeid=#{woeid} and u='#{format}'&format=json"

SCHEDULER.every '15m', :first_in => 0 do |job|
  http     = Net::HTTP.new "query.yahooapis.com"
  request  = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results  = response["query"]["results"]

  if results
    condition = results["channel"]["item"]["condition"]
    location  = results["channel"]["location"]
    send_event('weather', { :temp => "#{condition['temp']}&deg;#{format.upcase}",
                          :condition => condition['text'],
                          :title => "#{location['city']} Weather",
                          :climacon => climacon_class(condition['code'])})
  end


end


def climacon_class(weather_code)
  case weather_code.to_i
  when 0
    'tornado'
  when 1
    'tornado'
  when 2
    'tornado'
  when 3
    'lightning'
  when 4
    'lightning'
  when 5
    'snow'
  when 6
    'sleet'
  when 7
    'snow'
  when 8
    'drizzle'
  when 9
    'drizzle'
  when 10
    'sleet'
  when 11
    'rain'
  when 12
    'rain'
  when 13
    'snow'
  when 14
    'snow'
  when 15
    'snow'
  when 16
    'snow'
  when 17
    'hail'
  when 18
    'sleet'
  when 19
    'haze'
  when 20
    'fog'
  when 21
    'haze'
  when 22
    'haze'
  when 23
    'wind'
  when 24
    'wind'
  when 25
    'thermometer low'
  when 26
    'cloud'
  when 27
    'cloud moon'
  when 28
    'cloud sun'
  when 29
    'cloud moon'
  when 30
    'cloud sun'
  when 31
    'moon'
  when 32
    'sun'
  when 33
    'moon'
  when 34
    'sun'
  when 35
    'hail'
  when 36
    'thermometer full'
  when 37
    'lightning'
  when 38
    'lightning'
  when 39
    'lightning'
  when 40
    'rain'
  when 41
    'snow'
  when 42
    'snow'
  when 43
    'snow'
  when 44
    'cloud'
  when 45
    'lightning'
  when 46
    'snow'
  when 47
    'lightning'
  end
end
