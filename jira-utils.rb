class JiraUtil
	@@username = ""
	@@password = ""

        def self.username=(username)
            @@username=username
        end
        
        def self.password=(password)
            @@password=password
        end 

	def self.jira_client
	    options = {
		:username => @@username,
		:password => @@password,
		:site     => 'https://jira.mail.ru/',
		:context_path => '',
		:auth_type => :basic
	    }

	    client = JIRA::Client.new(options)
	end

	def self.issue_uri_str(issue_id)
	    "https://jira.mail.ru/browse/#{issue_id}"
	end

        def self.extract_issue_id(str)
            str[/[a-z]+-[1-9][0-9]+/i]
        end

	def self.issue_info(issue_id)
           return nil unless issue_id
	   client = self.jira_client() 
	   issue = client.Issue.find(issue_id)
	   result = nil
	   if issue && issue.attrs["fields"]
	       fields = issue.attrs["fields"]
               result = {}
	       result[:summary] = fields["summary"] || "<no summary>"
	       result[:description] = fields["description"] || "<no description>"
	       result[:created] = fields["created"] ? Time.parse(fields["created"]) : Time.at(0)
	   end
	   result
	end

end
