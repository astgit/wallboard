require 'twitter'

#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom

lending_twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = 'xKhyqOAvwB9u0gMEQs4oq7Fwe'
  config.consumer_secret = 'qWs4ewv5PNnj96Bkw5C6SnyBG78kUfezEenWEO4TCJaGVVPL6s'
  config.access_token = '750750885060435968-2rCAvlnZym7mMJF1QM32K2s917weJr6'
  config.access_token_secret = 'T33cTykbcpmnnPKm53ehwZhXTnAS9mQw12B7gBBOJByMq'
end

sales_twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = '7GmbpR4KygcX6bxQZs0bgk8b8'
  config.consumer_secret = 'YrUIfdVhbV657lnoSKGqznXB7TiypLu2F9Xz91jwqkXmBKFhfN'
  config.access_token = '751079876405424128-0g7P5WGjLCXVL8lsSHE8RYZiDTuiPa7'
  config.access_token_secret = '8kulrmNMzWXayQL5j9IucO9U4rLoLfiaEvSQNZTwfVmoN'
end

SCHEDULER.every '2m', :first_in => 0 do |job|
  begin
    lending_tweets = lending_twitter.user_timeline('ct_lending')
    sales_tweets = sales_twitter.user_timeline('ct_salesteam')
    if lending_tweets
      lending_tweet = lending_tweets.shift
      send_event('lending_twitter_latest', text: lending_tweet.text)
    end
    if sales_tweets
      sales_tweet = sales_tweets.shift
      send_event('sales_twitter_latest', text: sales_tweet.text)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end
