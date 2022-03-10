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
		assert_equal "Ihttps:", UrlCompressor.compressed_url("httpS://")
		assert_equal "C", UrlCompressor.compressed_url("httP://www.")
		assert_equal "Ihttp:", UrlCompressor.compressed_url("httP://")
		assert_equal "Ifoobar", UrlCompressor.compressed_url("foobar")
		assert_equal "H", UrlCompressor.compressed_url("")
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
		assert_equal "H", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "H", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/goo/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "Fapple.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.Apple.com/")
		assert_equal "Gapple.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://Apple.com/")
		assert_equal "Capple.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "http://www.apple.com/")
		assert_equal "H", UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.COM:443/")
		assert_nil UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", nil)
		assert_nil UrlCompressor.compressed_relative_url(nil, nil)
		assert_equal "Aapple.com", UrlCompressor.compressed_relative_url("bogus1", "https://www.apple.com/")
		assert_equal "Ibogus2", UrlCompressor.compressed_relative_url("bogus1", "bogus2")
		assert_equal "Agoldenhillsoftware.com", UrlCompressor.compressed_relative_url(nil, "httpS://www.goldenhillsoftware.com/")
		assert_equal "Agoldenhillsoftware.com", UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.COM:443/")
		assert_equal "Ex", UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/abcd/efgh/ijkl/mno", "httPS://www.goldenhillsoftware.com/abcd/efgh/x")
		assert_equal "Ex/", UrlCompressor.compressed_relative_url("httPS://www.goldenhillsoftware.com/abcd/efgh/ijkl/mno", "httPS://www.goldenhillsoftware.com/abcd/efgh/x/")
	end

	def test_from_compressed_relative_url
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "H")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/goo/feed/", "H")
		assert_equal "https://www.apple.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "Fapple.com/")
		assert_equal "https://apple.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "Gapple.com/")
		assert_equal "http://www.apple.com/", UrlCompressor.decompressed_relative_url("https://www.goldenhillsoftware.com/feed/", "Capple.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", "H")
		assert_nil UrlCompressor.decompressed_relative_url("httPS://www.goldenhillsoftware.com/feed/", nil)
		assert_nil UrlCompressor.decompressed_relative_url(nil, nil)
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url(nil, "Agoldenhillsoftware.com/")
		assert_equal "https://www.apple.com/", UrlCompressor.decompressed_relative_url("bogus1", "Aapple.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url(nil, "Agoldenhillsoftware.com/")
		assert_equal "https://www.goldenhillsoftware.com/", UrlCompressor.decompressed_relative_url("http://www.goldenhillsoftware.com/feed/", "Agoldenhillsoftware.com/")
	end
	
	def test_redirect_to_self
		assert_equal "I", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/feed/")
		assert_equal "Agoldenhillsoftware.com/feed/", UrlCompressor.compressed_relative_url("httpz://www.goldenhillsoftware.com/feed/", "httPS://wwW.Goldenhillsoftware.com/feed/")
	end
	
	def test_compressed_relative_root
		assert_equal "Agoldenhillsoftware.com", UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "Bgoldenhillsoftware.com", UrlCompressor.compressed_relative_url("http://www.goldenhillsoftware.com/feed/", "https://goldenhillsoftware.com/")
		assert_equal "Cgoldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "http://www.goldenhillsoftware.com/")
		assert_equal "Dgoldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "http://goldenhillsoftware.com/")
		assert_equal "Gfoo.goldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://foo.goldenhillsoftware.com/")
		assert_equal "Gfoo.goldenhillsoftware.com/a/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://foo.goldenhillsoftware.com/a/")
		assert_equal "Ffoo.goldenhillsoftware.com", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.foo.goldenhillsoftware.com/")
		assert_equal "Ffoo.goldenhillsoftware.com/a/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.foo.goldenhillsoftware.com/a/")
		assert_equal "H", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/")
		assert_equal "Hfoo", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/foo")
		assert_equal "Hfoo/", UrlCompressor.compressed_relative_url("https://www.goldenhillsoftware.com/feed/", "https://www.goldenhillsoftware.com/foo/")
	end
	
end
