source 'http://rubygems.org'

group :development, :test do
  if ENV['USE_LOCAL_SPREE']
    gem "spree_auth_devise", :path => "~/code/spree_auth_devise"
    gem 'spree_core', :path => '~/code/spree'
    gem 'spree_promo', :path => '~/code/spree'
  else
    gem "spree_auth_devise", :git => 'git://github.com/spree/spree_auth_devise.git', :branch => '1-3-stable'
  end
end

gemspec
