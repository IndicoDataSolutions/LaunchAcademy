require 'rubygems'
require 'oauth'
require 'json'

$baseurl = "https://api.twitter.com"
$consumer_key = OAuth::Consumer.new(
    "",
    ""
)

$access_token = OAuth::Token.new(
    "",
    ""
)

def find_tweets(user, hashtag, since_id)
	path = "/1.1/search/tweets.json"
	options = Hash.new()
	options["q"] = "@#{user} ##{hashtag}"
	options["result_type"] = "recent"
	options["count"] = "100"
	if since_id then
		options["since_id"] = since_id
	end 
	query = URI.encode_www_form(options)
	address = URI("#{$baseurl}#{path}?#{query}")

	request = Net::HTTP::Get.new address.request_uri

	response = send_request(address, request)
	return JSON.parse(response.body)["statuses"]
end

def send_request(address, request)
	http             = Net::HTTP.new address.host, address.port
	http.use_ssl     = true
	http.verify_mode = OpenSSL::SSL::VERIFY_PEER

	request.oauth! http, $consumer_key, $access_token
	http.start
	return http.request request
end

def monitor_tweets(user, hashtag)
	initial_tweets = find_tweets(user, hashtag, nil)
	since_id = nil
	if initial_tweets[0] then
		since_id = initial_tweets[0]["id"]
	end
	loop do
		puts "happening"
		sleep(10)
		new_tweets = find_tweets(user, hashtag, since_id)
		if new_tweets[0] then
			since_id = new_tweets[0]["id"]
			puts "new tweet!"
			for tweet in new_tweets
				if tweet["entities"].has_key?("media") then
					picture = tweet["entities"]["media"][0]["media_url"]
					puts picture
				end
			end
		end
	end
end

monitor_tweets("sl8rv", "koala")
