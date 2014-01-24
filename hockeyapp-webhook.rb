require 'json'
require 'cgi'
require 'net/http/server'
require 'pp'


Net::HTTP::Server.run(:port => 9674) do |request,stream|

    if request[:uri][:path] == '/hockeyapp'
        buf = ''
        len = request[:headers]["Content-Length"].to_i
        while (buf.bytesize<len && (chunk=stream.read(len-buf.length)))
            buf << chunk
        end

        crash_info = JSON.parse(buf)
        p = CGI::parse(request[:uri][:query].str)
        appname = p["appname"][0]
        if appname

            message = "[hockeyapp][crash-group] #{appname} #{p["crash_reason"]["bundle_short_version"]}(#{p["crash_reason"]["bundle_version"]} #{p["crash_reason"]["file"]}:#{p["crash_reason"]["line"]} #{p["crash_reason"]["class"]} #{p["crash_reason"]["reason"]} #{p["url"]}"

            irc_hook_uri = URI("http://johann.mail.msk:8667/post")
            irc_hook_uri.query = URI.encode_www_form("channel" => "#mailru-ios-mail", "message" => message)

            Net::HTTP.get(irc_hook_uri)
        end
    end

    [200, {'Content-Type' => 'text/html'}, ['OK']]

end
