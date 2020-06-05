# config valid for current version and patch releases of Capistrano
lock '~> 3.12.1'

set :application, 'bakerhub-indexer'
set :repo_url, 'git@github.com:figment-networks/bakerhub-indexer.git'

# use current local branch. deploy/production.rb forces master
set :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, '/home/bakerhub/app'

before 'deploy:check:linked_files', 'linked_files:upload_files'
append :linked_files, 'config/master.key'
append :linked_files, 'config/credentials.yml.enc'
append :linked_files, 'config/initializers/rack_attack.rb'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

set :default_env, { path: '/home/bakerhub/ruby/bin:$PATH' }
set :local_user, -> { 'bakerhub' }

set :keep_releases, 2

task :restart_web do
  on roles(:web) do
    execute 'sudo systemctl reload bakerhub-unicorn || sudo systemctl start bakerhub-unicorn'
  end
end

after 'deploy:symlink:release', :restart_web
