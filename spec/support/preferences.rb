# Resets all preferences to default values, you can
# pass a block to override the defaults with a block
#
# reset_spree_preferences do |config|
#   config.site_name = "my fancy pants store"
# end
#
def reset_spree_preferences(&block)
  Spree::Preferences::Store.instance.persistence = false
  Spree::Preferences::Store.instance.clear_cache
  configure_spree_preferences(&block) if block_given?
end

def configure_spree_preferences
  config = Rails.application.config.spree.preferences
  yield(config) if block_given?
end

def assert_preference_unset(preference)
  expect(find("#preferences_#{preference}")['checked']).to be(false)
  expect(Spree::Config[preference]).to be(false)
end