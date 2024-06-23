require "mechanize"
require "nokogiri"
require "json"
require "nkf"

def stats?(str)
  # 数値もしくは "-" の正規表現パターン
  pattern = /\A[0-9\-\.\/\+]+\z/

  # 文字列がパターンにマッチするかを判定
  str.match?(pattern)
end

def round_robin_to_hash( body )
  # Nokogiri を使用して HTML を解析
  doc = Nokogiri::HTML(body)

  hash = Hash.new

  current_stage  = nil

  players   = nil
  stats_list = nil

  # h5 要素とその後に続く td 要素を順に取得
  doc.xpath('//h5 | //tr').each do |element|
    if element.name == 'h5'
      current_stage = element.text.strip.sub("ラウンドロビン","").sub("　台番号:",",")
    elsif element.name == 'tr'
      tds = element.xpath('.//td').map(&:text)
      if players == nil
        players = tds
      elsif stats_list == nil
        stats_list = tds
      end
      if players != nil && stats_list != nil
        players.zip(stats_list).each{|player_info,stats_info|
          player_name, rank = player_info.scan(/^(.+?)\s*\((\d)位\)/).flatten
          wl, leg_point, stats = stats_info.split("/")
          win, lose = wl.split("-")
          rnum, machine = current_stage.split(",")
          hash[player_name] = { "win"=>win.to_i, "lose"=>lose.to_i, "leg_point"=>leg_point.to_i, "rank"=>rank.to_i, "rnum"=>rnum, "machine"=>machine.to_i, "stats"=>stats }
        }
        players = nil
        stats_list = nil
      end
    end
  end

  hash
end

if $0 == __FILE__
  url = ARGV[0] || "https://data.prodarts.jp/perfect/roundrobinview?conferenceId=230&sex=1"

  agent                  = Mechanize.new
  agent.user_agent       = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  agent.user_agent_alias = 'Windows IE 9'
  agent.read_timeout     = 30

  body = NKF.nkf("-w", agent.get(url).body)

  pp round_robin_to_hash( body )
end
