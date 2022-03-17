require 'minitest/autorun'
require 'urlcompressor'

class UrlCompressorTest < Minitest::Test

	def test_normalized_url
		assert_equal "https://www.goldenhillsoftware.com/foo", UrlCompressor.normalized_url("httpS://www.goldenhillsoftware.com:443/foo")
		assert_equal "foobar", UrlCompressor.normalized_url("foobar")
		assert_nil UrlCompressor.normalized_url(nil)
	end

	def test_compressed_url
		assert_equal "Agoldenhillsoftware.com/foo", UrlCompressor.compressed_url("httpS://www.goldenhillsoftware.com:443/foo")
		assert_equal "Agoldenhillsoftware.com/foo/", UrlCompressor.compressed_url("httpS://www.goldenhillsoftware.com:443/foo/")
		assert_equal "Bgoldenhillsoftware.com/foo", UrlCompressor.compressed_url("httpS://goldenhillsoftware.com:443/foo")
		assert_equal "Cgoldenhillsoftware.com/foo", UrlCompressor.compressed_url("httP://www.goldenhillsoftware.com:80/foo")
		assert_equal "Dgoldenhillsoftware.com/foo", UrlCompressor.compressed_url("httP://goldenhillsoftware.com:80/foo")
		assert_equal "Dgoldenhillsoftware.com", UrlCompressor.compressed_url("httP://goldenhillsoftware.com:80")
		assert_equal "Dgoldenhillsoftware.com", UrlCompressor.compressed_url("httP://goldenhillsoftware.com:80/")
		assert_equal "Dgoldenhillsoftware.com/?ab", UrlCompressor.compressed_url("httP://goldenhillsoftware.com:80/?ab")
		assert_equal "Dgoldenhillsoftware.com/#ab", UrlCompressor.compressed_url("httP://goldenhillsoftware.com:80/#ab")
		assert_equal "A", UrlCompressor.compressed_url("httpS://www.")
		assert_equal "Jhttps:", UrlCompressor.compressed_url("httpS://")
		assert_equal "C", UrlCompressor.compressed_url("httP://www.")
		assert_equal "Jhttp:", UrlCompressor.compressed_url("httP://")
		assert_equal "Jfoobar", UrlCompressor.compressed_url("foobar")
		assert_equal "I", UrlCompressor.compressed_url("")
		assert_nil UrlCompressor.compressed_url(nil)
	end

	def test_decompressed_url
		assert_equal "https://www.goldenhillsoftware.com/foo", UrlCompressor.decompressed_url(UrlCompressor.compressed_url("httpS://www.goldenhillsoftware.com:443/foo"))
		assert_equal "https://goldenhillsoftware.com/foo", UrlCompressor.decompressed_url(UrlCompressor.compressed_url("httpS://goldenhillsoftware.com:443/foo"))
		assert_equal "http://www.goldenhillsoftware.com/foo", UrlCompressor.decompressed_url(UrlCompressor.compressed_url("httP://www.goldenhillsoftware.com:80/foo"))
		assert_equal "http://goldenhillsoftware.com/foo", UrlCompressor.decompressed_url(UrlCompressor.compressed_url("httP://goldenhillsoftware.com:80/foo"))
		assert_equal "http://goldenhillsoftware.com/", UrlCompressor.decompressed_url(UrlCompressor.compressed_url("http://goldenhillsoftware.com/"))
		assert_equal "foobar", UrlCompressor.decompressed_url(UrlCompressor.compressed_url("foobar"))
		assert_nil UrlCompressor.compressed_url(nil)
	end
	
	def test_make_relative_url
		assert_equal "/", UrlCompressor.relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "//www.apple.com/", UrlCompressor.relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.apple.com/")
		assert_equal "http://www.apple.com/", UrlCompressor.relative_url("https://www.goldenhillsoftware.com/feed/", "http://www.apple.com/")
		assert_equal "/", UrlCompressor.relative_url("httPS://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.COM:443/")
		assert_equal "../x", UrlCompressor.relative_url("httPS://www.goldenhillsoftware.com/abcd/efgh/ijkl/mno", "httPS://www.goldenhillsoftware.com/abcd/efgh/x")
		assert_nil UrlCompressor.relative_url("httPS://www.goldenhillsoftware.com/feed/", nil)
		assert_nil UrlCompressor.relative_url(nil, nil)
		assert_equal "https://www.apple.com/", UrlCompressor.relative_url("bogus1", "https://www.apple.com/")
		assert_equal "bogus2", UrlCompressor.relative_url("bogus1", "bogus2")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.relative_url(nil, "httpS://www.goldenhillsoftware.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.relative_url("http://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.COM:443/")
		assert_equal "/abc?def", UrlCompressor.relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/abc?def")
		assert_equal "/abc?def#ghi", UrlCompressor.relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/abc?def#ghi")
		assert_equal "/abc#ghi", UrlCompressor.relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/abc#ghi")
	end

	def test_from_relative_url
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.from_relative_url("https://www.goldenhillsoftware.com/feed/", "../")
		assert_equal "https://www.apple.com/", UrlCompressor.from_relative_url("https://www.goldenhillsoftware.com/feed/", "//www.apple.com/")
		assert_nil UrlCompressor.from_relative_url("https://www.goldenhillsoftware.com/feed/", nil)
		assert_equal "https://www.goldenhillsoftware.com/feed/", UrlCompressor.from_relative_url(nil, "https://www.goldenhillsoftware.com/feed/")
	end
	
	def test_compressed_relative_url
		assert_equal "I", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "I", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/goo/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "Gapple.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.Apple.com/")
		assert_equal "Happle.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://Apple.com/")
		assert_equal "Capple.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "http://www.apple.com/")
		assert_equal "I", UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.COM:443/")
		assert_nil UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", nil)
		assert_nil UrlCompressor.compressed_relative_url(nil, nil)
		assert_equal "Aapple.com", UrlCompressor.compressed_relative_url("bogus1", "https://www.apple.com/")
		assert_equal "Jbogus2", UrlCompressor.compressed_relative_url("bogus1", "bogus2")
		assert_equal "Agoldenhillsoftware.com", UrlCompressor.compressed_relative_url(nil, "httpS://www.goldenhillsoftware.com/")
		assert_equal "Agoldenhillsoftware.com", UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.COM:443/")
		assert_equal "Ex", UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/abcd/efgh/ijkl/mno", "httPS://www.goldenhillsoftware.com/abcd/efgh/x")
		assert_equal "Ex/", UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/abcd/efgh/ijkl/mno", "httPS://www.goldenhillsoftware.com/abcd/efgh/x/")
	end

	def test_from_compressed_relative_url
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "I")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/goo/feed/", "I")
		assert_equal "https://www.apple.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "Gapple.com/")
		assert_equal "https://apple.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "Happle.com/")
		assert_equal "http://www.apple.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "Capple.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", "I")
		assert_nil UrlCompressor.decompressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", nil)
		assert_nil UrlCompressor.decompressed_relative_url(nil, nil)
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url(nil, "Agoldenhillsoftware.com/")
		assert_equal "https://www.apple.com/", UrlCompressor.decompressed_relative_url("bogus1", "Aapple.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url(nil, "Agoldenhillsoftware.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("http://www.goldenhillsoftware.com/feed/", "Agoldenhillsoftware.com/")
	end
	
	def test_redirect_to_self
		assert_equal "J", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/feed/")
		assert_equal "Agoldenhillsoftware.com/feed/", UrlCompressor.compressed_relative_url("httpz://www.goldenhillsoftware.com/feed/", "httPS://wwW.Goldenhillsoftware.com/feed/")
	end
	
	def test_compressed_relative_root
		assert_equal "Agoldenhillsoftware.com", UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "Bgoldenhillsoftware.com", UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://goldenhillsoftware.com/")
		assert_equal "Cgoldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "http://www.goldenhillsoftware.com/")
		assert_equal "Dgoldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "http://goldenhillsoftware.com/")
		assert_equal "Hfoo.goldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://foo.goldenhillsoftware.com/")
		assert_equal "Hfoo.goldenhillsoftware.com/a/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://foo.goldenhillsoftware.com/a/")
		assert_equal "Gfoo.goldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.foo.goldenhillsoftware.com/")
		assert_equal "Gfoo.goldenhillsoftware.com/a/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.foo.goldenhillsoftware.com/a/")
		assert_equal "I", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "Ifoo", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/foo")
		assert_equal "Ifoo/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/foo/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com"))
	end
	
	def test_trailing_slashes
		compressed = UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("http://www.goldenhillsoftware.com/feed/", compressed)
	end
	
	def test_relative_more
		assert_equal "I", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/feed.xml", "https://jaredsinclair.com/")
		assert_equal "Jfoo", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/feed.xml", "https://jaredsinclair.com/foo")
		assert_equal "Jfoo/", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/feed.xml", "https://jaredsinclair.com/foo/")
 
		assert_equal "J", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/", "https://jaredsinclair.com/")
		assert_equal "Jfoo", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/", "https://jaredsinclair.com/foo")
		assert_equal "Jfoo/", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/", "https://jaredsinclair.com/foo/")

		assert_equal "F", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/longassedprefix/feed.xml", "https://jaredsinclair.com/longassedprefix/")
		assert_equal "Jfoo", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/longassedprefix/feed.xml", "https://jaredsinclair.com/longassedprefix/foo")
		assert_equal "Jfoo/", UrlCompressor.compressed_relative_url("https://jaredsinclair.com/longassedprefix/feed.xml", "https://jaredsinclair.com/longassedprefix/foo/")

		assert_equal "https://jaredsinclair.com/", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/feed.xml", "I")
		assert_equal "https://jaredsinclair.com/foo", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/feed.xml", "Jfoo")
		assert_equal "https://jaredsinclair.com/foo/", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/feed.xml", "Jfoo/")

		assert_equal "https://jaredsinclair.com/", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/", "J")
		assert_equal "https://jaredsinclair.com/foo", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/", "Jfoo")
		assert_equal "https://jaredsinclair.com/foo/", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/", "Jfoo/")

		assert_equal "https://jaredsinclair.com/longassedprefix/", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/longassedprefix/feed.xml", "F")
		assert_equal "https://jaredsinclair.com/longassedprefix/foo", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/longassedprefix/feed.xml", "Jfoo")
		assert_equal "https://jaredsinclair.com/longassedprefix/foo/", UrlCompressor.decompressed_relative_url("https://jaredsinclair.com/longassedprefix/feed.xml", "Jfoo/")

		assert_equal "I", UrlCompressor.compressed_relative_url("https://bluelemonbits.com/feed/", "https://bluelemonbits.com")

	end
	
	def test_lossless
		assert_equal "Agoldenhillsoftware.coM:443/foo", UrlCompressor.losslessly_compressed_url("https://www.goldenhillsoftware.coM:443/foo")
		assert_equal "JhttPs://www.goldenhillsoftware.coM:443/foo", UrlCompressor.losslessly_compressed_url("httPs://www.goldenhillsoftware.coM:443/foo")
	
		assert_nil UrlCompressor.losslessly_compressed_url(nil)
		assert_nil UrlCompressor.losslessly_decompressed_url(nil)
	
		url_strings = [
			"httpS://www.goldenhillsoftware.com:443/foo/",
			"httpS://www.goldenhillsoftware.com:443/foo/",
			"httpS://goldenhillsoftware.com:443/foo",
			"httP://www.goldenhillsoftware.com:80/foo",
			"httP://goldenhillsoftware.com:80/foo",
			"httpS://www.goldenhillsoftware.com:443/foo",
			"httpS://www.goldenhillsoftware.com:443/foo/",
			"httpS://goldenhillsoftware.com:443/foo",
			"httP://www.goldenhillsoftware.com:80/foo",
			"httP://goldenhillsoftware.com:80/foo",
			"httP://goldenhillsoftware.com:80",
			"httP://goldenhillsoftware.com:80/",
			"httP://goldenhillsoftware.com:80/?ab",
			"httP://goldenhillsoftware.com:80/#ab",
			"httpS://www.",
			"httpS://",
			"httP://www.",
			"httP://",
			"foobar"
		]

		url_strings.each do |url_string|
			assert_equal url_string, UrlCompressor.losslessly_decompressed_url(UrlCompressor.losslessly_compressed_url(url_string))
		end
		
	end
	
	def test_site_specific
		assert_pair("https://medium.com/feed/abcdefg", "aabcdefg")
		assert_pair("https://medium.com/@jbrayton/feed", "bjbrayton/feed")
		assert_pair("http://www.blogger.com/feeds/25595390/posts/default", "c25595390/posts/default")
		assert_pair("https://feedpress.me/512pixels", "d512pixels")

		assert_pair("http://feeds.feedburner.com/37signals/beMH", "e37signals/beMH")
		assert_pair("https://feeds.feedburner.com/37signals/beMH", "f37signals/beMH")
		assert_pair("http://feeds2.feedburner.com/37signals/beMH", "g37signals/beMH")
		assert_pair("https://feeds2.feedburner.com/37signals/beMH", "h37signals/beMH")
		
		assert_pair("https://youtube.com/feeds/videos.xml?channel_id=UC3XTzVzaHQEd30rQbuvCtTQ", "iUC3XTzVzaHQEd30rQbuvCtTQ")
		assert_pair("https://youtube.com/feeds/videos.xml?playlist_id=PLYMMAhTaSiBM_eMmMotetfaNzynKGU9CQ", "jPLYMMAhTaSiBM_eMmMotetfaNzynKGU9CQ")

		assert_pair("https://world.hey.com/jordanmorgan/feed.atom", "kjordanmorgan/feed.atom")

		assert_pair("https://blogs.virtualsanity.com/foobar", "lvirtualsanity.com/foobar")
		assert_pair("http://blogs.virtualsanity.com/foobar", "mvirtualsanity.com/foobar")
		assert_pair("https://blog.virtualsanity.com/foobar", "nvirtualsanity.com/foobar")
		assert_pair("http://blog.virtualsanity.com/foobar", "ovirtualsanity.com/foobar")
		
		assert_pair("https://www.goldenhillsoftware.com/private/testfeed.xml?foobar=22bf6760-6dcd-4596-b9ed-6c8aad2999a1", "p22bf6760-6dcd-4596-b9ed-6c8aad2999a1")
		assert_pair("https://micro.virtualsanity.com/foobar", "svirtualsanity.com/foobar")

		assert_relative("https://www.youtube.com/feeds/videos.xml?channel_id=UCJ0uqCI0Vqr2Rrt1HseGirg", "https://www.youtube.com/channel/UCJ0uqCI0Vqr2Rrt1HseGirg", "qUCJ0uqCI0Vqr2Rrt1HseGirg")
		assert_relative("https://www.youtube.com/feeds/videos.xml?playlist_id=PLYMMAhTaSiBM_eMmMotetfaNzynKGU9CQ", "https://www.youtube.com/playlist?list=PLYMMAhTaSiBM_eMmMotetfaNzynKGU9CQ", "rPLYMMAhTaSiBM_eMmMotetfaNzynKGU9CQ")
	end
	
	def assert_pair(decompressed, compressed)
		assert_equal compressed, UrlCompressor.compressed_url(decompressed), "compression failed for #{decompressed}"
		assert_equal decompressed, UrlCompressor.decompressed_url(compressed), "decompression failed for #{compressed}"
	end
	
	def assert_relative(decompressed_origin_url, decompressed_relative, compressed_relative)
		assert_equal compressed_relative, UrlCompressor.compressed_relative_url(decompressed_origin_url, decompressed_relative), "compression failed for #{decompressed_relative} from #{decompressed_origin_url}"
		assert_equal decompressed_relative, UrlCompressor.decompressed_relative_url(decompressed_origin_url, compressed_relative), "decompression failed for #{compressed_relative} from #{decompressed_origin_url}"
	end
	
end
