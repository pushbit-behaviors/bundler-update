$stdout.sync = true
require "bundler"
require "json"
require "faraday"

specs = []

old_lockfile = Bundler::LockfileParser.new(Bundler.read_file("Gemfile.lock.old"))
new_lockfile = Bundler::LockfileParser.new(Bundler.read_file("Gemfile.lock"))

old_lockfile.specs.each do |s| 
  specs.push({
    name:s.name, 
    original:s.version.to_s,
    current: new_lockfile.specs.find { |v| puts v.inspect; puts s.inspect; v.name == s.name }.version.to_s
  }) 
end

diff = specs.select do |s|
  s[:original] != s[:current]
end

if diff.length == 0
  puts "no gems were updated :)"
  exit 0
end

message = "Hey! I just ran a bundle update on the project and it looks 
as though there are a number of gems that can be easily bumped up 
in version for increased stability and less bugs, here's a list:\r\n\r\n"

diff.each do |d|
  message += "#{d[:name]} v#{d[:current]} (previously v#{d[:original]})\r\n"
end

title = "#{diff.length} Gem#{"s" if diff.length > 1} Updated in your Bundle"

conn = Faraday.new(:url => ENV.fetch("APP_URL")) do |config|
  config.adapter Faraday.default_adapter
end

conn.post do |req|
  req.url '/discoveries'
  req.headers['Content-Type'] = 'application/json'
  req.headers['Authorization'] = "Basic #{ENV.fetch("ACCESS_TOKEN")}"
  req.body = {
    title: title,
    task_id: ENV.fetch("TASK_ID"),
    identifier: ENV.fetch("COMMIT"),
    kind: :dependencies,
    code_changed: true,
    priority: :unknown,
    message: message
  }.to_json
end
