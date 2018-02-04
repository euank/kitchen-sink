#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'set'

raise "Must have arguments: API_KEY BLOG_ID" if ARGV.size != 2

api_key = ARGV[0]
blog = ARGV[1]

offset=0

seen_ids = Set.new

loop do
  body = open("http://api.tumblr.com/v2/blog/#{blog}/posts?api_key=#{api_key}&offset=#{offset}").read

  resp = JSON.parse(body)

  if resp["meta"]["status"] != 200 then
    raise "Error #{resp["meta"]["status"]}"
  end

  posts = resp["response"]["posts"]

  posts.each do |post|
    id=post["id"]
    next if seen_ids.include?(id)
    seen_ids.add(id)

    File.open("#{id}.json", "w") do |f|
      f.write(JSON.pretty_generate(post))
    end
  end

  offset += posts.size

  break if posts.size == 0
end
