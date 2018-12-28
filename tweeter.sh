# For setting up simple chron job to send out tweet
ruby cthuhlu-generator.rb
t update "$(cat tweet.txt)"