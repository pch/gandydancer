require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'dotenv'
Dotenv.load

set :application, ENV.fetch('APPLICATION_NAME')
set :domain, ENV.fetch('APPLICATION_HOST')
set :deploy_to, ENV.fetch('DEPLOYMENT_ROOT')
set :repository, ENV.fetch('DEPLOYMENT_GIT_REPO_URL')
set :branch, ENV.fetch('DEPLOYMENT_BRANCH', 'master')
set :user, ENV.fetch('DEPLOYMENT_USER')
set :forward_agent, true

set :shared_dirs, ['log', 'tmp/pids', 'tmp/sockets', 'public/uploads', 'vendor/bundle', 'public/assets']
set :shared_files, ['.rbenv-vars']

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  command %{
echo "-----> Loading environment"
#{echo_cmd %[source ~/.bashrc]}
}
  invoke :'rbenv:load'
end

task :setup => :environment do
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"]

  command %(mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets")
  command %(chmod g+rx,u+rwx "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets")

  command %(mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids")
  command %(chmod g+rx,u+rwx "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids")

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/public/uploads"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/public/uploads"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/public/assets"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/public/assets"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/vendor/bundle"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/vendor/bundle"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    on :launch do
      command %{
      echo "-----> Loading environment"
      #{echo_cmd %[source ~/.bashrc]}
      }

      command 'sudo systemctl restart sidekiq'
      command 'bundle exec pumactl phased-restart'
      # command 'sudo systemctl restart puma'
    end
  end
end
