require 'jira'
require 'rss'
require 'set'
require 'uri'
require_relative 'jira-utils.rb'

unless ARGV.length==2
    puts "Usage: #{File.basename($0)} <jira-user> <jira-password>"
    exit(1)
end

JiraUtil.username=ARGV[0]
JiraUtil.password=ARGV[1]

uri = URI("https://jira.mail.ru/sr/jira.issueviews:searchrequest-rss/temp/SearchRequest.xml")
uri.query = URI.encode_www_form("jqlQuery" => "project = \"Почта iOS\" ORDER BY created DESC", "tempMax" => 50)

items = [].to_set

while 1 do
    open(uri,:http_basic_authentication=>[ARGV[0],ARGV[1]]) do |rss|
        feed = RSS::Parser.parse(rss,false)
        received_set = feed.items.map { |item| 
                                               item.author ||= "<no author>"
                                               item.title  ||= "<no title>"
                                               item.link   ||= "<no link>"
                                               { 
                                                 :author => item.author, 
                                                 :title => item.title, 
                                                 :link => item.link, 
                                               } 
                                      }.to_set
        unless items.length == 0
            diff = received_set - items
            unless diff.length == 0
                diff.each { |item|
	                jira_issue = JiraUtil.issue_info(JiraUtil.extract_issue_id(item[:title]))
		            unless jira_issue
                        puts "Failed to get jira issue for #{item}"
                        next
                    end
                    # We may get OLD tasks here in case of task deletion.
                    # Filtering them.
                    if Time.now - jira_issue[:created] < 60*60 
                        message = "[jira][new-issue] #{item[:author]} #{item[:title]} #{item[:link]}"

                        irc_hook_uri = URI("http://johann.mail.msk:8667/post")
                        irc_hook_uri.query = URI.encode_www_form("channel" => "#mailru-ios-mail", "message" => message)

                        Net::HTTP.get(irc_hook_uri)
                    end
                }
            end
        end
        items = received_set
    end
    sleep 10
end
