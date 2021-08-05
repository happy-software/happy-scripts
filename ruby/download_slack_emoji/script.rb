require "fileutils"
require "json"
require "net/http"
require "optparse"
require "pry"

options = { buffer_size: 200 }.tap do |options|
  OptionParser.new do |opts|
    opts.banner = "Usage: script.rb [options]"

    opts.on("-f", "--filepath FILEPATH", "FILEPATH to response with all slack emoji") do |filepath|
      options[:filepath] = filepath
    end

    opts.on("-b", "--buffer-size SIZE", Integer, "The number of emoji to download at a time. Defaults to 200.") do |buffer_size|
      options[:buffer_size] = buffer_size
    end
  end.parse!
end

this_directory = File.absolute_path(__dir__)

response_filepath = options[:filepath]
raise "Could not find the file: #{response_filepath}" unless File.exist?(response_filepath)
response_file = File.read(response_filepath)

data_directory_name = "downloaded_slack_emoji"
data_directory = File.join(this_directory, data_directory_name)

puts "Creating the data directory"
if Dir.exists?(data_directory)
  puts "The directory #{data_directory_name} already exists, cannot continue"
else
  FileUtils.mkdir_p(data_directory)
  puts "Created the data directory: #{data_directory_name}"
end

dataset = JSON.parse(response_file, symbolize_names: true)
emoji = dataset[:emoji]
buffer_size = options[:buffer_size]

data_to_save = emoji.each_slice(buffer_size).to_a.each_with_object({ good: [], bad: [] }) do |emoji_slice, output|
  # let's try to throttle the downloads
  emoji_slice.each do |name, url|
    begin
      unless url.is_a?(String)
        output[:bad].push({ name: name, url: url })
        next
      end

      uri = URI(url)

      if uri.scheme != "https"
        output[:bad].push({ name: name, url: url })
        next
      end

      response = Net::HTTP.get_response(URI(url))

      body = response.body

      if response.is_a?(Net::HTTPSuccess)
        puts "Downloaded #{name}"
        output[:good].push({ name: name, image_content: body, extension: url.split('.').last })
      else
        output[:bad].push({ name: name, url: url })
      end
    rescue => e
      puts e
      output[:bad].push({ name: name, url: url })
    ensure
      sleep(0.3)
    end
  end

  puts(<<~MSG.strip)
    Downloaded #{buffer_size} files. Currently have #{output[:good].size} good files (total files: #{emoji.keys.size})"
    Taking a little nap.."
  MSG

  sleep(60)
end

data_to_save[:good].each do |emoji_data|
  filename = "#{emoji_data[:name]}.#{emoji_data[:extension]}"
  new_filepath = File.join(data_directory, filename)

  puts "Writing #{filename}"

  File.open(new_filepath, "w+") { |file| file.write(emoji_data[:image_content]) }

  puts "Wrote #{filename}"
end
