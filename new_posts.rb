#!/usr/bin/env ruby

require 'erb'
require 'rexml/document'
require 'net/http'
require 'uri'

if ARGV.length > 2
	puts "new_posts.rb takes one argument, the feed you want to get new posts from"
	exit(1)
end

@posts_feed = ARGV[0]
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
		@posts.push({:title => item.elements["title"].text, :link => item.elements["link"].text, :date => item.elements["pubDate"].text, :description => item.elements["description"].text})
		@counter += 1
	end

rescue Exception => ex
	puts "Could not get feed from #{@posts_feed}"
	puts ex
	exit(1)
end

html_for_posts = ERB.new <<EOF
<% @posts.each do |post| %>
<h2><a href="<%=puts post[:link]%>" rel="bookmark" title="Permanent Link to <%=post[:title]%>"><%=post[:title]%></a></h2>
				<small><%=post[:date]%></small>
	<p>
		<%=post[:description]%><a href="<%=post[:link]%>">Read more...</a>
	</p>
<% end %>
EOF

puts html_for_posts.result
