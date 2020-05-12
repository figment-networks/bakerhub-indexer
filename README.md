# README

## Setup Instructions

* Clone this repo
* Set up encrypted credentials using the example in `config/credentials.example.yml`
* `bundle install` to install gems
* `rails db:create db:migrate db:seed` to set up your databsae
* `rake sync` to sync the Tezos chain data
* `rails s` to serve the API
