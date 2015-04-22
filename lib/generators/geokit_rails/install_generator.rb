module GeokitRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a sample Geokit initializer."

      def copy_initializer
        copy_file "geokit_config.rb", "config/initializers/geokit_config.rb"
      end
    end
  end
end
