module Misc
  def read_file( path )
    if File.exist?(path)
      body = File.read(path)
      body = NKF.nkf( "-w", body )
    else
      body = ""
    end
    body
  end

  def refer( agent, filepath, url )
    if File.exist?( filepath )
      body = read_file( filepath )
    else
      body = agent.get(url).body
      body = NKF.nkf( "-w", body )
      STDERR << "[Fetch ] " + url + "\n"
      dir  = File.dirname( filepath )
      FileUtils.mkdir_p dir if !File.exist?( dir )
      file = open( filepath, "w" )
      file.puts body
      file.close
    end
    body
  end
end
