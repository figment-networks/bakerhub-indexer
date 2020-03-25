require 'capistrano/setup'

require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'whenever/capistrano' unless ENV['NO_CRONTAB_SETUP']
require 'capistrano/linked_files'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
