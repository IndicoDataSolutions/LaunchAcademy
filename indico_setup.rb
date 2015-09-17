require 'indico'
require 'open-uri'

Indico.api_key = ""

def create_features(in_file, out_file)
	image_data = Array.new
	urls = File.readlines(in_file) 
	urls.each do |line|
		url_data = Base64.encode64(open(line) { |io| io.read })
		image_data.push(url_data)
	end
	features = Indico.image_features(image_data)
	url_mapping = Hash.new
	urls.zip(features).each do |url, feature_vector|
		url_mapping[url] = feature_vector
	end

	File.open(out_file,"w") do |f|
		f.write(url_mapping.to_json)
	end
end

create_features("pictures.csv", "image_features.json")