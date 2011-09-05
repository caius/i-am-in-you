require "rubygems"
require "bundler/setup"

require "curb"
require "erb"
require "cgi"
require "json"

# YQL has a much higher API limit, proxy through them
response = JSON.parse(Curl::Easy.perform("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20twitter.search%20where%20q%3D'I%20AM%20IN%20YOU'%3B&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=").body_str)

# Yay, YQL
tweets = response["query"]["results"]["results"]

# Make sure they match what we actually want
tweets.select {|tweet| tweet["text"][/\w+[, -]I AM IN YOU/i] }

# Write it out
File.open("public/index.html", "w") do |f|
  f.puts ERB.new(DATA.read, 0, '>').result
end

__END__
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
  <head>
    <title>I AM IN YOU</title>
    <meta name="content-type" content="utf8">
  </head>
  <body>
    <ul id="tweets">
      <% tweets.each do |tweet| %>
        <li>
          <span class="body"><%= CGI.escapeHTML(tweet["text"]) %></span> &mdash; <a href="https://twitter.com/<%= tweet["from_user"] %>"><%= tweet["from_user"] %></a>
        </li>
      <% end %>
    </ul>
  </body>
</html>
