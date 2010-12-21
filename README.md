Store Credits
=============

This Spree extension allows admins to issue arbitrary amounts of store credit to users.

Users can redeem store credit during checkout, as part or full payment for an order.

Also extends My Account page to display outstanding credit balance, and orders that used store credit.

Installation
============

1. Add the following to your applications Gemfile

    gem 'spree_store_credits'

2. Run bundler

    bundle install

3. Copy assests / migrations (note: this will change after Rails 3.1).

    rails g spree_store_credits:install -f

4. Run migrations

    rake db:migrate


Copyright (c) 2010 Roman Smirnov, released under the New BSD License
