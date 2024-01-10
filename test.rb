require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "nokogiri"
require "open-uri"
require "date"

doc = Nokogiri::HTML(URI.open("http://ufcstats.com/fighter-details/07f72a2a7591b409"))
fighter_stats = doc.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_middle-width.js-guide.clearfix > div.b-list__info-box-left.clearfix")

stat_values = fighter_stats.css("li").text.split("          ")

clean_stat_values = []

stat_values.each do |value|
  if value == "\n" || value == "\n\n" || value == ""
    next
  else
    value = value.delete("/n").strip
    if value == ""
      next
    else
    clean_stat_values.push(value)
    end
  end
end

stat_values_hash = Hash[*clean_stat_values.flatten(1)]


p stat_values_hash
