require 'rubygems'
require 'oauth'
require 'json'
require 'indico'
require 'open-uri'

Indico.api_key = ""

$baseurl = "https://api.twitter.com"
$consumer_key = OAuth::Consumer.new(
    "",
    ""
)

$access_token = OAuth::Token.new(
    "",
    ""
)

$image_database = JSON.parse(File.read("image_features.json"))


def post_tweet(body)
	path    = "/1.1/statuses/update.json"
	address = URI("#{$baseurl}#{path}")
	request = Net::HTTP::Post.new address.request_uri
	request.set_form_data(
	  "status" => body,
	)

	response = send_request(address, request)

	if response.code == '200' then
	  tweet = JSON.parse(response.body)
	  puts "Successfully sent #{tweet["text"]}"
	else
	  puts "Could not send the Tweet! " +
	  "Code:#{response.code} Body:#{response.body}"
	end
end

def get_image_features(image_url)
	url_data = Base64.encode64(open(image_url) { |io| io.read })
	return Indico.image_features(url_data)
end

def find_closest_image(image_url)
	query_features = get_image_features(image_url)
	distances = []
	$image_database.each do |url, features|
		distances.push(euclidean_distance(query_features, features))
	end
	minimum = distances.each_with_index.min
	return $image_database.keys[minimum[1]]
end

def euclidean_distance(vector1, vector2)
	distance = 0
	vector1.zip(vector2).each do |v1, v2|
		distance += (v1 - v2) ** 2
	end
	return distance
end

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
			for tweet in new_tweets
				if tweet["entities"].has_key?("media") then
					picture = tweet["entities"]["media"][0]["media_url"]
					nearest_picture = find_closest_image(picture)
					random_string = ('a'..'z').to_a.shuffle[0,8].join
					post_tweet("Great picture %s! This is your spirit Border Collie: %s Random String: %s" % [tweet["user"]["name"], nearest_picture, random_string])
					puts picture
				end
			end
		end
	end
end

monitor_tweets("sl8rv", "koala")
