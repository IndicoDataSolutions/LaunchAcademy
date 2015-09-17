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

def find_tweets(user, hashtag)
	path = "/1.1/search/tweets.json"
	query = URI.encode_www_form(
		"q" => "@#{user} ##{hashtag}"
	)
	address = URI("#{$baseurl}#{path}?#{query}")

	request = Net::HTTP::Get.new address.request_uri

	response = send_request(address, request)
	puts JSON.parse(response.body)
end

def send_request(address, request)
	http             = Net::HTTP.new address.host, address.port
	http.use_ssl     = true
	http.verify_mode = OpenSSL::SSL::VERIFY_PEER

	request.oauth! http, $consumer_key, $access_token
	http.start
	return http.request request
end

find_tweets("sl8rv", "bigdata")
