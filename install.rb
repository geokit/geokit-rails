# Display to the console the contents of the README file.
puts IO.read(File.join(File.dirname(__FILE__), 'README.markdown'))

# place the api_keys_template in the application's /config/initializers/geokit_config.rb
path=File.expand_path(File.join(File.dirname(__FILE__), '../../../config/initializers/geokit_config.rb'))
template_path=File.join(File.dirname(__FILE__), '/assets/api_keys_template')
if File.exists?(path)
  puts "It looks like you already have a configuration file at #{path}. We've left it as-is. Recommended: check #{template_path} to see if anything has changed, and update config file accordingly."
else
  File.open(path, "w") do |f|
    f.puts IO.read(template_path)
    puts "We created a configuration file for you in config/initializers/geokit_config.rb. Add your Google API keys, etc there."
  end  
end
