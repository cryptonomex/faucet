require 'mina/git'
require 'mina/bundler'
require 'mina/rails'
require 'mina/rbenv'
require 'mina/rsync'
require 'yaml'

DEPLOY_CONF = YAML.load(File.read('config/deploy.yml'))

set :domain, DEPLOY_CONF['host']
set :user, DEPLOY_CONF['user']
set :deploy_to, '/www'
set :repository, DEPLOY_CONF['repository']
set :branch, DEPLOY_CONF['branch']
set :shared_paths, ['log', 'config/faucet.yml', 'config/secrets.yml', 'public/wallet']
set :rsync_options, %w[-az --force --recursive --delete --delete-excluded --progress --exclude-from=.gitignore --exclude 'public/*']

task :environment do
    invoke :'rbenv:load'
end

task :setup => :environment do
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/public/wallet"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
end

task :deploy => :environment do
    deploy do
        invoke :'rsync:deploy'
        invoke :'deploy:link_shared_paths'
        invoke :'bundle:install'
        invoke :'rails:db_migrate'
        invoke :'rails:assets_precompile'
        to :launch do
            queue "touch #{deploy_to}/tmp/restart.txt"
        end
    end
end

task :restart do
    queue 'sudo service nginx restart'
end

task :wallet do
    $script =
<<SCRIPT
      echo 'deploying wallet';
      rsync -az --force --delete --progress public/wallet/ #{domain}:#{deploy_to}/#{shared_path}/public/wallet;
SCRIPT
    exec $script
    to :launch do
        queue "touch #{deploy_to}/tmp/restart.txt"
    end
end
