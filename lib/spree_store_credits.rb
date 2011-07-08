require 'spree_core'

module SpreeStoreCredits
  class Engine < Rails::Engine
    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env == "production" ? require(c) : load(c)
      end

      # this line is so important (borrowed from spree_promo).  I don't know why, but there's a chicken/egg
      # issue when running rake test_app.
      # the migrations fail b/c the app gets its activate method called, which tries regist a promotion, but
      # the activator table doesn't yet exist.
      if Activator.table_exists?
        Promotion::Actions::GiveStoreCredit.register
      end
    end

    config.to_prepare &method(:activate).to_proc
    config.autoload_paths += %W(#{config.root}/lib)
  end
end

