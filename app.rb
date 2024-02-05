require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "nokogiri"
require "open-uri"
require "date"


get("/") do
  redirect("/upcoming_fights2")
end

get("/upcoming_fights2") do
  sports_key = ENV.fetch("SPORTS_KEY")
  sports_api_url = "https://api.the-odds-api.com/v4/sports/mma_mixed_martial_arts/odds/?apiKey=#{sports_key}&regions=us&markets=h2h,spreads&oddsFormat=american"
  sports_fetch = HTTP.get(sports_api_url)
  @sports_parse = JSON.parse(sports_fetch)
  erb(:upcoming_fights2)
end

get("/:fighter1/:fighter2/:fight_id") do
  @fighter1 = params.fetch("fighter1")
  @fighter2 = params.fetch("fighter2")




  sports_key = ENV.fetch("SPORTS_KEY")
  sports_api_url = "https://api.the-odds-api.com/v4/sports/mma_mixed_martial_arts/odds/?apiKey=#{sports_key}&regions=us&markets=h2h,spreads&oddsFormat=american"
  sports_fetch = HTTP.get(sports_api_url) 
  @sports_parse = JSON.parse(sports_fetch)
  @fighter1_odds = 0
  @fighter2_odds = 0
  @sports_parse.each do |fight|
    if fight.fetch("id") == params.fetch("fight_id")
      if fight.fetch("bookmakers").length > 0
        @fighter1_odds = fight.dig("bookmakers", 0, "markets", 0)
        @fighter1_odds = @fighter1_odds.fetch("outcomes")
        @fighter1_odds.each do |fighter|
          if fighter.fetch("name") == @fighter1
            @fighter1_odds = fighter.fetch("price").to_i
          end
        end
      
        @fighter2_odds = fight.dig("bookmakers", 0, "markets", 0)
        @fighter2_odds = @fighter2_odds.fetch("outcomes")
        @fighter2_odds.each do |fighter|
          if fighter.fetch("name") == @fighter2
            @fighter2_odds = fighter.fetch("price").to_i
          end
        end
    
    
        if @fighter1_odds > 0
          @fighter1_odds = "+" + @fighter1_odds.to_s
        end
        if @fighter2_odds > 0
          @fighter2_odds = "+" + @fighter2_odds.to_s
        end
      end
    end
  end

  #Pulls the fighter1 data from  UFCstats.com

  
  fighter1 = @fighter1.split(" ")
  fighter1_lastname = fighter1[1]
  fighter1_firstname = fighter1[0]

  @url1 = "http://ufcstats.com/statistics/fighters/search?query=#{fighter1_lastname}"
  @doc1 = Nokogiri::HTML(URI.open("http://ufcstats.com/statistics/fighters/search?query=#{fighter1_lastname}"))



  @fighter1_link = ""
  @links1 = @doc1.css("body > section > div > div > div > table a")
  @links1.each do |link|
    if link.content == fighter1_firstname
      @fighter1_link = link["href"]
      break
    end
  end
  
  @doc12 = Nokogiri::HTML(URI.open(@fighter1_link))
  # @text = @doc2.xpath("/html/body/section/div/div/div[1]/ul/li[1]").text.strip
  @text12 = @doc12.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_small-width.js-guide > ul").text.strip

  @record1 = @doc12.css("body > section > div > h2 > span.b-content__title-record")

  @fighter1_data = @text12.split(" ")
  @fighter1_height = @fighter1_data.at(1) + " " + @fighter1_data.at(2)
  @fighter1_weight = @fighter1_data.at(4) + " " + @fighter1_data.at(5)
  @fighter1_reach = @fighter1_data.at(7)
  @fighter1_stance = @fighter1_data.at(9)
  @fighter1_dob_s = @fighter1_data.at(11) + " " + @fighter1_data.at(12) + " " + @fighter1_data.at(13)
  @fighter1_dob = DateTime.parse(@fighter1_dob_s)
  now = Date.today
  @fighter1_age = ((now - @fighter1_dob)/365).to_i
  @fight_history1 = @doc12.css("body > section > div > div > table")

  fighter_stats1 = @doc12.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_middle-width.js-guide.clearfix > div.b-list__info-box-left.clearfix")

  stat_values1 = fighter_stats1.css("li").text.split("          ")

  clean_stat_values1 = []
  
  stat_values1.each do |value|
    if value == "\n" || value == "\n\n" || value == ""
      next
    else
      value = value.delete("/n").strip
      if value == ""
        next
      else
      clean_stat_values1.push(value)
      end
    end
  end
  
  @stat_values_hash1 = Hash[*clean_stat_values1.flatten(1)]

  #Pulls the fighter2 data from  UFCstats.com

     

  fighter2 = @fighter2.split(" ")
  fighter2_lastname = fighter2[1]
  fighter2_firstname = fighter2[0]

  @url2 = "http://ufcstats.com/statistics/fighters/search?query=#{fighter2_lastname}"
  @doc2 = Nokogiri::HTML(URI.open("http://ufcstats.com/statistics/fighters/search?query=#{fighter2_lastname}"))



  @fighter2_link = ""
  @links2 = @doc2.css("body > section > div > div > div > table a")
  @links2.each do |link|
    if link.content == fighter2_firstname
      @fighter2_link = link["href"]
      break
    end
  end
  
  @doc22 = Nokogiri::HTML(URI.open(@fighter2_link))
  # @text = @doc2.xpath("/html/body/section/div/div/div[1]/ul/li[1]").text.strip
  @text22 = @doc22.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_small-width.js-guide > ul").text.strip

  @record2 = @doc22.css("body > section > div > h2 > span.b-content__title-record")

  @fighter2_data = @text22.split(" ")
  @fighter2_height = @fighter2_data.at(1) + " " + @fighter2_data.at(2)
  @fighter2_weight = @fighter2_data.at(4) + " " + @fighter2_data.at(5)
  @fighter2_reach = @fighter2_data.at(7)
  @fighter2_stance = @fighter2_data.at(9)
  @fighter2_dob_s = @fighter2_data.at(11) + " " + @fighter2_data.at(12) + " " + @fighter2_data.at(13)
  @fighter2_dob = DateTime.parse(@fighter2_dob_s)
  now = Date.today
  @fighter2_age = ((now - @fighter2_dob)/365).to_i
  @fight_history2 = @doc22.css("body > section > div > div > table")

  fighter_stats2 = @doc22.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_middle-width.js-guide.clearfix > div.b-list__info-box-left.clearfix")

  stat_values2 = fighter_stats2.css("li").text.split("          ")

  clean_stat_values2 = []
  
  stat_values2.each do |value|
    if value == "\n" || value == "\n\n" || value == ""
      next
    else
      value = value.delete("/n").strip
      if value == ""
        next
      else
      clean_stat_values2.push(value)
      end
    end
  end
  
  @stat_values_hash2 = Hash[*clean_stat_values2.flatten(1)]






  
  erb(:fight_summary)


  
end

get("/:fighter") do
  @fighter = params.fetch("fighter")
  fighter = @fighter.split(" ")
  fighter_lastname = fighter[1]
  fighter_firstname = fighter[0]

  @url = "http://ufcstats.com/statistics/fighters/search?query=#{fighter_lastname}"
  @doc = Nokogiri::HTML(URI.open("http://ufcstats.com/statistics/fighters/search?query=#{fighter_lastname}"))
  # @url_html = HTTP.get(url).to_s

  # @data = Nokogiri::HTML(open(doc))


  @fighter_link = ""
  @links = @doc.css("body > section > div > div > div > table a")
  
  @links.each do |link|
    if link.content == fighter_firstname
      @fighter_link = link["href"]
      break
    end
  end
  
  @doc2 = Nokogiri::HTML(URI.open(@fighter_link))
  # @text = @doc2.xpath("/html/body/section/div/div/div[1]/ul/li[1]").text.strip
  @text2 = @doc2.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_small-width.js-guide > ul").text.strip

  @record = @doc2.css("body > section > div > h2 > span.b-content__title-record")

  @fighter_data = @text2.split(" ")
  @fighter_height = @fighter_data.at(1) + " " + @fighter_data.at(2)
  @fighter_weight = @fighter_data.at(4) + " " + @fighter_data.at(5)
  @fighter_reach = @fighter_data.at(7)
  @fighter_stance = @fighter_data.at(9)
  @fighter_dob_s = @fighter_data.at(11) + " " + @fighter_data.at(12) + " " + @fighter_data.at(13)
  @fighter_dob = Date.parse(@fighter_dob_s)
  now = Date.today
  @fighter_age = ((now - @fighter_dob)/365).to_i

  @fight_history = @doc2.css("body > section > div > div > table")

  fighter_stats = @doc2.css("body > section > div > div > div.b-list__info-box.b-list__info-box_style_middle-width.js-guide.clearfix > div.b-list__info-box-left.clearfix")

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
  
  @stat_values_hash = Hash[*clean_stat_values.flatten(1)]
  

  


  


  erb(:fighter_profile)
end
