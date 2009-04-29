require 'lib/extra'
require 'rubygems'
require 'open-uri'

begin
  require 'simple-rss'
rescue LoadError
  puts "sudo gem install simple-rss"
  exit 1
end

class GithubTail
  def initialize
    @save_file = "#{ENV['HOME']}/.github_tail.db"
    @state = {}
    @feed = 'http://github.com/timeline.atom'
  end

  def every(dt)
    while true
      load_state
      show
      save_state
      sleep dt
    end
  rescue Interrupt
    save_state
  end
  
private

  def yellow(t)
    "\033[01;31m#{t}\033[00m"
  end

  def green(t)
    "\033[01;32m#{t}\033[00m"
  end

  def show
    items = new_items
    puts '--' if items.any?
    items.each do |item|
      item[:title] =~ /(.*?) (.*) (.*?)$/
      person = $1
      stuff = $2
      repo = $3
      puts "#{yellow(person)} #{stuff} #{green(repo)}"
      puts "  #{item[:link]}"
    end
  end

  def new_items
    SimpleRSS.parse(open(@feed)).items.reject { |i|
      filter i
    }.map { |i|
      @state[i[:id]] = true
      i
    }
  end

  def filter(i)
    @state[i[:id]] ? i : nil
  end

  def load_state
    @state = Marshal.load(File.read(@save_file))
  rescue
    false
  end

  def save_state
    File.open(@save_file, 'w') do |f|
      f << Marshal.dump(@state)
    end
  end

  def self.poll
    GithubTail.new
  end
end
