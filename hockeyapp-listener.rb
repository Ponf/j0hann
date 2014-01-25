require 'json'
require 'net/http'
require 'set'
require 'uri'
require 'open-uri'
require_relative 'irc-utils.rb'

HOCKEYAPP_TOKEN=""
APP_INFOS=[
              {
                  "name" => "",
                  "id" => ""
              },
          ]

cache = {}
while 1
    APP_INFOS.each { |app_info|
        app_name = app_info["name"]
        app_id = app_info["id"]

        cache[app_id] ||= [].to_set
        hockey_uri_str = "https://rink.hockeyapp.net/api/2/apps/#{app_id}/crash_reasons?symbolicated=1&page=1&order=desc&per_page=100"
        open(hockey_uri_str,"X-HockeyAppToken" => HOCKEYAPP_TOKEN) { |f|
            response = f.read
            reports = JSON.parse(response)["crash_reasons"].map { |cr|
                                                                    {
                                                                        "id" => cr["id"],
                                                                        "app_id" => cr["app_id"],
                                                                        "version" => "#{cr["bundle_short_version"]}.#{cr["bundle_version"]}",
                                                                        "reason" => cr["reason"],
                                                                        "file" => cr["file"],
                                                                        "line" => cr["line"]
                                                                    }
                                                                }
            unless cache[app_id].length == 0
                diff = cache[app_id] - reports
                diff.each { |r|
                    
                    crash_url = "https://rink.hockeyapp.net/manage/apps/#{r["app_id"]}/crash_reasons/#{r["id"]}"
                    message = " ".color(:brown)+"[hockeyapp][crash-group]".bold
                    message += "#{app_name} #{r["version"]} #{r["file"]}:#{r["line"]} #{r["reason"]} #{crash_url}"

                    IRCUtils.post(message)
                }
            end
            cache[app_id] = reports
        }
    }
    sleep(60)
end
