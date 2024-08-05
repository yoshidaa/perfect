require "mechanize"
require "nokogiri"
require "json"
require "nkf"

def numeric_or_dash?(str)
  # 数値もしくは "-" の正規表現パターン
  pattern = /\A[0-9\-\.]+\z/

  # 文字列がパターンにマッチするかを判定
  str.match?(pattern)
end

def tournament_result_to_hash( body )
  # Nokogiri を使用して HTML を解析
  doc = Nokogiri::HTML(body)

  hash = Hash.new
  current_stage  = nil
  current_player = nil

  # h5 要素とその後に続く td 要素を順に取得
  doc.xpath('//h5 | //td').each do |element|
    if element.name == 'h5'
      current_stage = element.text.strip
      hash[current_stage] = Hash.new
    elsif element.name == 'td'
      if numeric_or_dash?(element.text.strip)
        hash[current_stage][current_player]["stats"].push( element.text.strip )
      else
        current_player = element.text.strip
        current_player = current_player.sub(/\s+/," ")
        hash[current_stage][current_player] = { "stats"=>Array.new }
      end
    end
  end

  hash.each{|stage_name,shash|
    shash.keys.each_slice(2){|winner,loser|
      shash[winner]["opponent"]        = loser
      shash[winner]["win"]             = true
      shash[winner]["opponent_scores"] = shash[loser]["stats"]
      shash[loser ]["opponent"]        = winner
      shash[loser ]["win"]             = false
      shash[loser ]["opponent_scores"] = shash[winner]["stats"]
    }
  }

  hash
end

if $0 == __FILE__
  url = ARGV[0] || "https://member.prodarts.jp/tournament_result_stats.php?tournament_no=280&mem_sex_cd=1"

  agent                  = Mechanize.new
  agent.user_agent       = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  agent.user_agent_alias = 'Windows IE 9'
  agent.read_timeout     = 30

  body = NKF.nkf("-w", agent.get(url).body)

  pp tournament_result_to_hash( body )
end
