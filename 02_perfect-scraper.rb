require "mechanize"
require "nokogiri"
require "date"
require "json"
require "pp"
require "yaml"
require_relative "./lib/misc"
require_relative "./lib/round_robin"
require_relative "./lib/tournament_results"

include Misc

if $0 == __FILE__
  agent                  = Mechanize.new
  agent.user_agent       = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  agent.user_agent_alias = 'Windows IE 9'
  agent.read_timeout     = 30

  data = JSON.load_file("01_summary.json")
  data.each{|year,yhash|
    yhash.each{|date,dhash|
      dhash["round_robin"] = dhash["url"]["round_robin"].map{|url|
        id, sex = url.scan(/conferenceId=(\d+)&sex=(\d)/).flatten
        filepath = sprintf("./raw/round_robin/rr%s_%d.html", date, sex)
        body = Misc::refer( agent, filepath, url )
        [ sex, round_robin_to_hash( body ) ]
      }.to_h
      dhash["tournament_result_stats"] = dhash["url"]["tournament_result_stats"].map{|url|
        id, sex = url.scan(/tournament_no=(\d+)&mem_sex_cd=(\d)/).flatten
        filepath = sprintf("./raw/tournament_results/tr%s_%d.html", date, sex)
        body = Misc::refer( agent, filepath, url )
        [ sex, tournament_result_to_hash( body ) ]
      }.to_h
    }
  }

  hash = Hash.new

  members = YAML.load_file("players.yaml")

  members.each{|sex_str, players|
    players.each{|player_name|
      sex = sex_str == "男子" ? "1" : "2"
      data.keys.reverse.each{|year|
        yhash = data[year]
        yhash.keys.reverse.each{|date|
          dhash = yhash[date]
          next unless dhash["round_robin"][sex] && dhash["round_robin"][sex][player_name]
          hash[player_name] ||= Hash.new
          hash[player_name][year] ||= Hash.new
          hash[player_name][year][date] = { "round_robin"=>dhash["round_robin"][sex][player_name],
                                            "num"=>dhash["num"],
                                            "place"=>dhash["place"],
                                            "tournament"=>Hash.new }
          dhash["tournament_result_stats"][sex].keys.reverse.each{|stage|
            if dhash["tournament_result_stats"][sex][stage].keys.include?(player_name)
              hash[player_name][year][date]["tournament"][stage.sub("ベスト","BEST ")] = dhash["tournament_result_stats"][sex][stage][player_name]
            end
          }
        }
      }
    }
  }

  output_json = JSON.pretty_generate(hash)
  File.write('./docs/data.json', output_json)
  # pp data
end
