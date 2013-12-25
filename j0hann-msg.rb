require 'net/http'
require 'uri'

uri = URI(ARGV[0])
uri.query = URI.encode_www_form("channel" => ARGV[1], "message" => STDIN.read.strip)

Net::HTTP.get(uri)


