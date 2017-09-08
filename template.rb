def source_paths
  Array(super) +
    [File.join(File.expand_path(File.dirname(__FILE__)), 'templates')]
end

def configure_application_file(config)
  inject_into_file(
    "config/application.rb",
    "\n\n    #{config}",
    before: "\n  end"
  )
end

def configure_environment(rails_env, config)
  inject_into_file(
    "config/environments/#{rails_env}.rb",
    "\n\n  #{config}",
    before: "\nend"
  )
end

def action_mailer_host(rails_env, host)
  config = "config.action_mailer.default_url_options = { host: #{host} }"
  configure_environment(rails_env, config)
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

gem 'redis-rails'
gem 'rack-canonical-host'
gem 'rack-mini-profiler', require: false

gem 'autoprefixer-rails'
gem 'simple_form'
gem 'bourbon'

gem_group :development do
  gem 'mina'
  gem 'mina-puma', require: false
  gem 'mina-whenever', require: false
  gem 'letter_opener'
  gem 'web-console'
end

gem_group :development, :test do
  gem 'awesome_print', require: 'ap'
  gem 'bundler-audit', '>= 0.5.0', require: false
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
end

gem_group :test do
  gem 'timecop'
  gem 'webmock'
  gem 'selenium-webdriver'
  gem 'capybara-selenium'
end

create_file '.ruby-version', '2.4.1'
copy_file 'Procfile', 'Procfile'
directory 'dotfiles', '.'

template 'bin/setup', 'bin/setup', force: true
template 'README.md.erb', 'README.md', force: true
run 'chmod a+x bin/setup'

run 'bundle install'
run 'rails generate simple_form:install'

#
# Config
#
config = <<-RUBY

    config.generators do |generate|
      generate.helper false
      generate.javascripts false
      generate.stylesheets false
    end

    config.action_controller.action_on_unpermitted_parameters = :raise
    config.assets.quiet = true

  RUBY

inject_into_class 'config/application.rb', 'Application', config

inside 'config' do
  copy_file 'puma.rb', force: true
  copy_file 'deploy.rb'
  copy_file 'smtp.rb'
  template 'database.yml.erb', 'database.yml', force: true
end

prepend_file 'config/environments/production.rb',
  %{require Rails.root.join("config/smtp")\n}

config = <<-RUBY

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = SMTP_SETTINGS
RUBY

inject_into_file 'config/environments/production.rb', config,
  after: "config.action_mailer.raise_delivery_errors = false"

gsub_file 'config/environments/development.rb', 'raise_delivery_errors = false', 'raise_delivery_errors = true'

config = <<-RUBY

  config.action_mailer.delivery_method = :letter_opener
RUBY
inject_into_file 'config/environments/development.rb', config,
  after: "config.action_mailer.raise_delivery_errors = true"

action_mailer_host 'development', %{ENV.fetch("APPLICATION_HOST")}
action_mailer_host 'test', %{"www.example.com"}
action_mailer_host 'production', %{ENV.fetch("APPLICATION_HOST")}

#
# Initializers
#
inside 'config/initializers' do
  remove_file 'wrap_parameters.rb'

  copy_file 'errors.rb'
  copy_file 'json_encoding.rb'
  copy_file 'rack_mini_profiler.rb'
end

#
# Stylesheets
#
inside 'app/assets/stylesheets' do
  remove_file 'application.css'
  copy_file 'application.scss'
  copy_file 'simple_form.scss'
  directory 'components'
end

#
# Helpers
#
copy_file 'app/helpers/shared_helper.rb', 'app/helpers/shared_helper.rb', force: true

#
# Views
#
inside 'app/views' do
  copy_file 'application/_flashes.html.erb'
  copy_file 'application/_javascript.html.erb'
  copy_file 'application/_css_overrides.html.erb'
  copy_file 'application/_analytics.html.erb'

  template 'layouts/application.html.erb.erb', 'layouts/application.html.erb', force: true
end

configure_environment 'test', 'config.active_job.queue_adapter = :inline'
configure_environment 'test', 'config.assets.raise_runtime_errors = true'

unless ENV['SKIP_SIDEKIQ']
  #
  # Sidekiq
  #
  gem 'sidekiq'
  gem 'sidekiq-failures'

  configure_application_file 'config.active_job.queue_adapter = :sidekiq'

  inside 'config' do
    copy_file 'sidekiq.yml'
  end

  prepend_file 'config/routes.rb', %{require 'sidekiq/web'\n}

  route 'mount Sidekiq::Web => "/sidekiq"'
end

unless ENV['SKIP_AUTH']
  #
  # User auth boilerplate
  #
  gem 'bcrypt', '~> 3.1.7'
  gem 'email_address'

  run 'rails g model user email password_digest auth_token:string:index password_reset_token password_reset_sent_at:datetime role'

  inside 'app/controllers' do
    directory 'concerns'
    copy_file 'sessions_controller.rb'
    copy_file 'signups_controller.rb'
    copy_file 'password_resets_controller.rb'
  end

  inside 'app/mailers' do
    copy_file 'user_mailer.rb'
  end

  inside 'app/models' do
    copy_file 'guest_user.rb'
    copy_file 'user.rb', 'user.rb', force: true
    copy_file 'concerns/users/auth.rb'
  end

  inside 'app/views' do
    directory 'sessions'
    directory 'signups'
    directory 'password_resets'
    directory 'user_mailer'
  end

  inject_into_class 'app/controllers/application_controller.rb', 'ApplicationController', "  include Auth\n"

  route "get 'sign-up',  to: 'signups#new', as: 'signup'"
  route "get 'sign-in',  to: 'sessions#new', as: 'login'"
  route "get 'sign-out', to: 'sessions#destroy', as: 'logout'"
  route "resources :signups, only: [:new, :create]"
  route "resources :sessions, only: [:new, :create, :destroy]"
  route "resources :password_resets, path: 'password-resets', only: [:new, :create, :edit, :update]"

  inside 'lib' do
    copy_file 'admin_constraint.rb'
  end

  prepend_file 'config/routes.rb', %{require_dependency "admin_constraint"\n}
end

copy_file "bundler_audit.rake", "lib/tasks/bundler_audit.rake"
append_file "Rakefile", %{\ntask default: "bundle:audit"\n}

run 'bundle install'

rake 'db:reset'
rake 'db:reset', env: 'test'
rake 'db:migrate'
rake 'db:migrate', env: 'test'

run 'rails g controller home index --skip-routes=true'
route "root to: 'home#index'"
