Spree Store Credits
===================

[![Build
Status](https://secure.travis-ci.org/spree/spree_store_credits.png)](http://travis-ci.org/spree/spree_store_credits)


This Spree extension allows admins to issue arbitrary amounts of store credit to users.

Users can redeem store credit during checkout, as part or full payment for an order.

Also extends My Account page to display outstanding credit balance, and orders that used store credit.

Installation
============

1. Add the following to your applications Gemfile

    gem 'spree_store_credits'

2. Run bundler

    bundle install

3. Copy and execute migrations:

    rails g spree_store_credits:install


Configuration
=============

By default Spree Store Credits does not require your order total to be above an amount to apply store credits.

To chanage this, use the :use_store_credit_minimum preference. For information on setting Spree preferences visit http://guides.spreecommerce.com/developer/preferences.html

One possible implementation looks like this:

```ruby
# app/model/spree/store_credit_decorator.rb

Spree::StoreCredit.class_eval do
  Spree::Config[:use_store_credit_minimum] = 0.01
end
```
