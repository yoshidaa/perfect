require "mechanize"
require "nokogiri"
require "date"
require "json"
require_relative "./lib/misc"

include Misc

if $0 == __FILE__
  agent                  = Mechanize.new
  agent.user_agent       = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  agent.user_agent_alias = 'Windows IE 9'
  agent.read_timeout     = 30

  START_YEAR = 2016
  years = Date.today.year.downto(START_YEAR).to_a.reverse

  hash  = Hash.new

  date_modifier = { "20160222"=>"20160220" }

  years.each{|year|
    url = "https://www.prodarts.jp/?touryear=#{year}result"
    body = agent.get(url).body
    sleep 1
    doc = Nokogiri::HTML(body)
    doc.xpath('//h4').each{|element|
      if element.name == "h4" && element.text.strip =~ /(.+戦)【(.+?)】([\d\.]+)/
        h          = Hash.new
        h["num"]   = $1
        h["place"] = $2
        h["date"]  = Date.parse($3).strftime("%Y%m%d")
        if date_modifier[h["date"]]
          h["date"] = date_modifier[h["date"]]
        end
        h["url"]   = Hash.new
        h["url"]["main"] = "https://www.prodarts.jp/result/#{h["date"]}/"
        _body = Misc::refer( agent, "raw/result_top/rt#{h["date"]}.html", h["url"]["main"] )
        _doc = Nokogiri::HTML(_body)
        h["url"]["round_robin"] = _doc.xpath('//a').map{|link| link["href"] }.select{|href|
          href.include?('roundrobinview')
        }.uniq
        h["url"]["tournament_result_stats"] = _doc.xpath('//a').map{|link| link["href"] }.select{|href|
          href.include?('tournament_result_stats.php')
        }.uniq
        hash[year] ||= Hash.new
        hash[year][h["date"]] = h
      end
    }
  }

  file = open("01_summary.json","w")
  file.puts hash.to_json
  file.close
end
