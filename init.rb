# So we don't trip up the rake gems:install which I'm running to install the gem this plugin requires!
unless $gems_rake_task
  require 'geokit-rails'
end
