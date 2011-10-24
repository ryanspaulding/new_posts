#!/usr/bin/env ruby

require 'erb'
require 'rexml/document'
require 'net/http'
require 'uri'
require 'date'

# set this if you do not want to pass a URL on the commandline 
URL = nil 

# little function to append 'st, nd, rd or th' after the day of the month:
# October 10th, 2011
def ordinalize(day)
	if (11..13).include?(day % 100)
      		return "#{day}th"
    	else
      		case day % 10
        		when 1; return "#{day}st"
        		when 2; return "#{day}nd"
        		when 3; return "#{day}rd"
        		else    return "#{day}th"
      		end
	end

end


if URL.nil? and ARGV.length > 2
	puts "new_posts.rb takes one argument, the feed you want to get new posts from"
	exit(1)
end

if URL.nil? or not ARGV[0].nil?
	@posts_feed = ARGV[0]
else
	@posts_feed = URL
end

if ARGV[1].nil?
	@limit = 3
else
	@limit = ARGV[1].to_i
end

@counter = 0
@posts = []

begin
	url = URI.parse(@posts_feed)
	req = Net::HTTP::Get.new(url.path)
	res = Net::HTTP.start(url.host, url.port) { |http|
		http.request(req)
	}
	feed = REXML::Document.new(res.body)

	feed.elements.each('rss/channel/item') do |item|
		if @counter == @limit
			break
		end
		# dates are stored in the following format => Mon, 10 Oct 2011 06:21:20 +0000
		# and we want them to look like this => October 20th, 2011
		@date_pieces = item.elements["pubDate"].text.split(" ")
		@good_date = "#{@date_pieces[2]}/#{@date_pieces[1]}/#{@date_pieces[3]}"
		# now the format is the format it is in not the format you want
		@nice_date = Date.strptime(@good_date, "%b/%d/%Y")
		@posts.push({:title => item.elements["title"].text, :link => item.elements["link"].text, :date => @nice_date.strftime("%B #{ordinalize(@nice_date.day)}, %Y"), :description => item.elements["description"].text})
		@counter += 1
	end

rescue Exception => ex
	puts "Could not get feed from #{@posts_feed}"
	puts ex
	exit(1)
end

html_for_posts = ERB.new <<EOF
<% @posts.each do |post| %>
<h2><a href="<%=post[:link]%>" rel="bookmark" title="Permanent Link to <%=post[:title]%>"><%=post[:title]%></a></h2>
				<small><%=post[:date]%></small>
	<p>
		<%=post[:description]%> <a href="<%=post[:link]%>">Read more...</a>
	</p>
<% end %>
EOF

puts html_for_posts.result
