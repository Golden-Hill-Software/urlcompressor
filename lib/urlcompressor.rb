require 'uri'

class Pair
	
	attr_accessor :short_prefix
	attr_accessor :long_prefix
	
	def initialize(short_prefix, long_prefix)
		@short_prefix = short_prefix
		@long_prefix = long_prefix
	end
	
end

class UrlCompressor

	PAIRS = [

		Pair.new("a", "https://medium.com/feed/"),
		Pair.new("b", "https://medium.com/@"),
		Pair.new("c", "http://www.blogger.com/feeds/"),
		Pair.new("d", "https://feedpress.me/"),
		Pair.new("e", "http://feeds.feedburner.com/"),
		Pair.new("f", "https://feeds.feedburner.com/"),
		Pair.new("g", "http://feeds2.feedburner.com/"),
		Pair.new("h", "https://feeds2.feedburner.com/"),
		Pair.new("i", "https://youtube.com/feeds/videos.xml?channel_id="),
		Pair.new("j", "https://youtube.com/feeds/videos.xml?playlist_id="),
		Pair.new("k", "https://world.hey.com/"),

		Pair.new("l", "https://blogs."),
		Pair.new("m", "http://blogs."),
		Pair.new("n", "https://blog."),
		Pair.new("o", "http://blog."),

		Pair.new("p", "https://www.goldenhillsoftware.com/private/testfeed.xml?foobar="),

		# for relative urls for YouTube Website URLs
		Pair.new("q", "/channel/"),
		Pair.new("r", "/playlist?list="),
		Pair.new("s", "https://micro"),

		Pair.new("A", "https://www."),
		Pair.new("B", "https://"),
		Pair.new("C", "http://www."),
		Pair.new("D", "http://"),
		Pair.new("E", "../"), # Note that this only removes the first ../
		Pair.new("F", "./"), # Note that this only removes the first ../
		Pair.new("G", "//www."),
		Pair.new("H", "//"),
		Pair.new("I", "/"),
		Pair.new("J", ""),
	]

	def self.normalized_url(url_string)
		if url_string.nil?
			return nil
		else
			begin
				return URI(url_string).normalize.to_s
			rescue
				return url_string
			end
		end
	end

	def self.compressed_url(url_string)
		normalized = normalized_url(url_string)
		compressed_url_string = compressed_url_string(normalized)
		if !compressed_url_string.nil? and compressed_url_string.index('/') == compressed_url_string.length - 1
			compressed_url_string = compressed_url_string[0..compressed_url_string.length-2]
		end
		return compressed_url_string
	end
	
	def self.decompressed_url(compressed_url_string)
		result = decompressed_url_string(compressed_url_string)
		begin
			uri = URI(result)
			if uri.path.nil? or uri.path.length == 0
				uri.path = "/"
			end
			result = uri.to_s
		rescue
		end
		return result
	end
	
	def self.relative_url(origin_url_string, url_string)
		if url_string.nil?
			return nil
		end
		if origin_url_string.nil?
			return normalized_url(url_string)
		end
		begin
			normalized_origin = URI(origin_url_string).normalize
			normalized_dest = normalized_url(url_string)
			likely_result = normalized_origin.route_to(normalized_dest).to_s
			
			# We know that likely_result will work, route_to tends to use "../" to navigate up, even
			# starting from the root would be shorter. Try to do that and see if we get a better result
			if !likely_result.start_with?("../") and !likely_result.start_with?("./")
				return likely_result
			end
			
			begin
				uri = URI(url_string)
				if uri.path.nil? or uri.path.empty?
					uri.path = "/"
				end
				from_root = uri.path
				if !uri.query.nil? and uri.query.length > 0
					from_root += "?#{uri.query}"
				end
				if !uri.fragment.nil? and uri.fragment.length > 0
					from_root += "##{uri.fragment}"
				end
				if (from_root.length <= likely_result.length) and from_relative_url(origin_url_string, likely_result) == from_relative_url(origin_url_string, from_root)
					return from_root
				else
					return likely_result
				end
			rescue
				return likely_result
			end
			
		rescue
			return url_string
		end
	end
	
	def self.from_relative_url(origin_url_string, relative_url)
		if origin_url_string.nil?
			return relative_url
		end
		if relative_url.nil?
			return nil
		end
		return URI.join(origin_url_string, relative_url).to_s
	end
	
	def self.decompressed_relative_url(decompressed_origin_url_string, compressed_relative_url)
		if compressed_relative_url.nil?
			return nil
		end
		if compressed_relative_url.start_with?("A") or compressed_relative_url.start_with?("B") or compressed_relative_url.start_with?("C") or compressed_relative_url.start_with?("D") or compressed_relative_url.start_with?("G") or compressed_relative_url.start_with?("H")
			if !compressed_relative_url.nil? and compressed_relative_url.index("/").nil?
				compressed_relative_url = compressed_relative_url + "/"
			end
		end
		decompressed_relative_url = decompressed_url_string(compressed_relative_url)
		return from_relative_url(decompressed_origin_url_string, decompressed_relative_url)
	end
	
	def self.compressed_relative_url(decompressed_origin_url_string, relative_url)
		relative_url = relative_url(decompressed_origin_url_string, relative_url)
		if relative_url.nil?
			return nil
		end
		compressed_url_string = compressed_url_string(relative_url)

		if compressed_url_string.start_with?("A") or compressed_url_string.start_with?("B") or compressed_url_string.start_with?("C") or compressed_url_string.start_with?("D") or compressed_url_string.start_with?("G") or compressed_url_string.start_with?("H")
			if !compressed_url_string.nil? and compressed_url_string.index('/') == compressed_url_string.length - 1
				compressed_url_string = compressed_url_string[0..compressed_url_string.length-2]
			end
		end
		
		return compressed_url_string

	end
	
	# For when we really need to regenerate the string -- presumably but not necessarily a URL -- exactly as it
	# was read in. No normalizing. Used for Websub topics, where the strings are server-specified, and I can't assume
	# (or trust) that the topic is a URL or that the server can handle insignificant differences.
	
	def self.losslessly_compressed_url(url_string)
		compressed_url_string = compressed_url_string(url_string)
		if !compressed_url_string.nil? and compressed_url_string.index('/') == compressed_url_string.length - 1
			compressed_url_string = compressed_url_string[0..compressed_url_string.length-2]
		end
		return compressed_url_string
	end
	
	def self.losslessly_decompressed_url(compressed_url_string)
		return decompressed_url_string(compressed_url_string)
	end
	
	private
	
	def self.compressed_url_string(url_string)
		if url_string.nil?
			return nil
		end
		PAIRS.each do |pair|
			if url_string == pair.long_prefix
				return pair.short_prefix
			elsif url_string.start_with?(pair.long_prefix)
				return "#{pair.short_prefix}#{url_string[pair.long_prefix.length...]}"
			end
		end
	end

	def self.decompressed_url_string(compressed_url_string)
		if compressed_url_string.nil?
			return nil
		end
		PAIRS.each do |pair|
			if compressed_url_string == pair.short_prefix
				return pair.long_prefix
			elsif compressed_url_string.start_with?(pair.short_prefix)
				return "#{pair.long_prefix}#{compressed_url_string[pair.short_prefix.length...]}"
			end
		end
	end

end

