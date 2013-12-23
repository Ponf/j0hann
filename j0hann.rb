require 'cinch'
require 'net/http/server'
require 'cgi'
require 'pp'

bot = Cinch::Bot.new do
    configure do |c|
        c.server = "smirn0v.ru"
        c.user = "j0hann"
        c.password = "bulletj0hann31337"
        c.channels = ["#mailru-ios-mail"]
    end

    on :message, "hello" do |m|
        m.reply "Hello, #{m.user.nick}"
    end
end

Net::HTTP::Server.run(:port => 8080, :background => true) do |request,stream|
  
  if request[:uri][:path] == '/post'
      params = CGI::parse(request[:uri][:query].str)
      channel = params["channel"][0]
      message = params["message"][0]
      if channel && message
          bot.Channel(channel).send(message)
      end
  end

  [200, {'Content-Type' => 'text/html'}, ['OK']]

end

bot.start
