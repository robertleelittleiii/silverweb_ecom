# frozen_string_literal: true

module SilverwebEcom
  class Engine < ::Rails::Engine
    require 'geocoder'
    require 'activemerchant'
    require 'pdfkit'
    require 'square_connect'

    #       require 'activerecord-session-store'

    #        require 'ssl_requirement'
    config.middleware.use PDFKit::Middleware

    # load all local migrations
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
