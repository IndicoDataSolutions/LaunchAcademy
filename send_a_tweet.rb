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

def send_request(address, request)
	http             = Net::HTTP.new address.host, address.port
	http.use_ssl     = true
	http.verify_mode = OpenSSL::SSL::VERIFY_PEER

	request.oauth! http, $consumer_key, $access_token
	http.start
	return http.request request
end

body = "CodeAcademy Tutorials make the twitter API easy"
post_tweet(body)
