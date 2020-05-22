# README

## Setup Instructions

* Clone this repo
* Set up encrypted credentials using the example in `config/credentials.example.yml`
* `bundle install` to install gems
* `rails db:create db:migrate db:seed` to set up your databsae
* `rake sync` to sync the Tezos chain data
* `rake sync_governance` to sync Tezos chain governance data
* `rails s` to serve the API

## API Docs

* API Docs are built with Vuepress and located in `/docs`
* View online at https://figment-networks.github.io/bakerhub-indexer/
