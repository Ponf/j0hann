require 'cinch'
require 'net/http/server'
require 'jira'
require 'cgi'
require 'pp'

bot = Cinch::Bot.new do
    configure do |c|
        c.server = ""
        c.user = ""
        c.password = ""
        c.channels = [""]
    end

    helpers do

        def allowed(message)
            #todo: runtime management ?
            white_list = ['smirn0v','karimov','shmat1ay','panfilov','rumiantsev']
            raise 'Not allowed' unless white_list.include?(message.user.authname)
        end

        def jira_client
            options = {
                :username => "",
                :password => "",
                :site     => 'https://jira.mail.ru/',
                :context_path => '',
                :auth_type => :basic
            }

            client = JIRA::Client.new(options)
        end

        def issue_uri_str(issue_id)
            "https://jira.mail.ru/browse/#{issue_id}"
        end
        
        def issue_info(issue_id, with_description = false)
           client = jira_client() 
           issue = client.Issue.find(issue_id)
           result = nil
           if issue 
               fields = issue.attrs["fields"]
               summary = nil
               description = nil
               if fields
                   summary = fields["summary"]
                   description = fields["description"] || "<no description>"
               end 
               if fields && summary
                   result = "#{issue_uri_str(issue_id)}: #{summary}"
                   if with_description
                       result += "\n  #{description.lines[0..15].join("  ")}"
                   end
               end 
           end
           result
        end

        def ios_issue_info(short_issue_id,with_description=false)
            return issue_info("iosmail-"+short_issue_id,with_description)
        end
    end

    on :message, /(\!|(iosmail\-))([1-9][0-9]+)/ do |m,g1,g2,identifier|
        allowed(m)
        m.reply(ios_issue_info(identifier))
    end

    on :message, /^!task ([1-9][0-9]+)$/ do |m,query|
        allowed(m)
        m.reply(ios_issue_info(query,with_description=true))
    end
end

Net::HTTP::Server.run(:port => 8667, :background => true) do |request,stream|
  
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
