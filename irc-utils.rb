class String
    COLOR_TABLE = {
        :white       => 0,
        :black       => 1,
        :blue        => 2,
        :green       => 3,
        :red         => 4,
        :brown       => 5,
        :purple      => 6,
        :orange      => 7,
        :yellow      => 8,
        :light_green => 9,
        :teal        => 10,
        :light_cyan  => 11,
        :light_blue  => 12,
        :pink        => 13,
        :grey        => 14,
        :light_grey  => 15,
    }

    def color(foreground,background=nil) 
        prefix = "\x03%02d"%COLOR_TABLE[foreground]
        prefix += ",%02d"%COLOR_TABLE[background] if background
        "#{prefix}#{self}\x03"
    end
    
    def bold
        "\x02#{self}\x0F"
    end
end
module IRCUtils
    def post(message)
        irc_hook_uri = URI("http://johann.mail.msk:8667/post")
        irc_hook_uri.query = URI.encode_www_form("channel" => "#mailru-ios-mail", "message" => message)

        Net::HTTP.get(irc_hook_uri)
    end

    module_function :post
end
