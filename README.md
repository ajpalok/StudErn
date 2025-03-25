# StudErn

## Start the server

To start the server using procfile, the following command was used:

```bash
bundle exec rails s -p 3000
```

## Initial Setup

### Start to build from scratch

This site was created with the command

```bash
rails new StudErn --database=mysql --skip-docker --skip-test --skip-bundle
```

### Alternative way to start: Download the repository and install the dependencies

After downloading the repository, the following command was used to install the dependencies:

```bash
bundle install
```

### Set local Gem setup on vendor directory

To set the local gem setup on vendor directory, the following command was used:

```bash
bundle config set --local path 'vendor/bundle'
```

### Extra dependencies for cPanel deployment

Then The site was deployed to a shared hosting server using cPanel. The following steps were required to deploy the site:

- It is required to have updated bundler. So run `gem install bundler rails` to install the latest version of bundler and rails.

- It was required to have `gem 'psych', '~>4.0.0'` in the Gemfile to avoid the error `Could not find 'psych' (>= 0)`

- Also **ruby-lsapi** gem was required to install in production machine to remove the error `Could not find 'lsapi' (>= 0)`

- Finally, the command `rails assets:precompile` was used to precompile the assets in production environment.

Then basic layouts and CSS were added to the site.  
Now the site is ready to have more updates and features.

## Authentication

The site uses the gem `devise` for authentication. The following command was used to install the gem:

```bash
rails generate devise:install
```

### Basic setup

Then the following command was used to generate the User model:

```bash
rails generate devise User
```

Depending on your application's configuration some manual setup may be required:

1. Ensure you have defined default url options in your environments files. Here is an example of default_url_options appropriate for a development environment in config/environments/development.rb:

    ```rb
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    ```

    In production, :host should be set to the actual host of your application.  
    *Required for all applications.*

2. Ensure you have defined root_url to *something* in your config/routes.rb. For example:

    ```rb
    root to: "home#index"
    ```

3. Ensure you have flash messages in app/views/layouts/application.html.erb. For example:

    ```rb
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
    ```

    *Not required for API-only Applications*
4. You can copy Devise views (for customization) to your app by running:

    ```bash
        rails g devise:views users
    ```

    *Not required*

### Multiple Authentication Models

To setup multiple authentication models, we have to update the config of devise in `config/initializers/devise.rb` file.

```rb
config.scoped_views = true
```

Then we can generate the model with the following command:

```bash
rails generate devise control_unit
```

### Customizing Devise model based views

To customize the views of the devise model, we can generate the views with the following command:

```bash
rails generate devise:views control_unit
```

Force to use the views of the devise model, we can use the following command:

```bash
rails generate devise:controllers control_unit
```

Update the routes in `config/routes.rb` file:

```rb
  devise_for :control_units,
              path: 'control_unit',
              path_names:
              {
                sign_in: 'login',
                sign_out: 'logout',
                sign_up: 'register',
                confirmation: 'verification',
                registration: 'account',
                cancel: 'close'
              },
              controllers:
              {
                sessions: 'control_unit/sessions',
                registrations: 'control_unit/registrations',
                confirmations: 'control_unit/confirmations',
                unlocks: 'control_unit/unlocks',
                omniauth: 'control_unit/omniauth_callbacks'
              }

```

### Adding Custom Fields to Devise Model

To add custom fields to the devise model, we have to generate the migration with the following command:

```bash
rails generate migration AddFieldsToControlUnit name:string
```

Then we have to update the migration file with the following code:

```rb
class AddFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :control_units, :name, :string
  end
end
```

Then we have to run the migration with the following command:

```bash
rails db:migrate
```

### Permitting custom fields in Devise

To permit the custom fields in the devise model, we have to update the `application_controller.rb` file with the following code:

```rb
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
```

or for any specific devise model, we can update the controller with the following code:

```rb
class ControlUnit::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
```

## Creating models, controllers and views with generators

### Creating a new model through model generator

For creating a new model, the following command was used: (Example: Post model)

```bash
rails g model post imageLink:string imageAlt:string title:string description:text postHealth:integer postStatus:integer user:references
```

Then the migration was run with the following command:

```bash
rails db:migrate
```

### Creating a new controller through controller generator

For creating a new controller, the following command was used: (Example: Post controller)

```bash
rails g controller posts index show new create edit update destroy
```

### Creating a new view for the controller through view generator

For creating a new view, the following command was used: (Example: Post view)

```bash
rails g view posts index show new edit
```

### Creating a new model with scaffold generator

For creating a new model with scaffold, the following command was used: (Example: Post model)

```bash
rails g scaffold post imageLink:string imageAlt:string title:string description:text postHealth:integer postStatus:integer user:references
```

Then the migration was run with the following command:

```bash
rails db:migrate
```

## New layout after application layout

### Creating a new layout

For creating a new layout, we need to make a new file in `app/views/layouts` directory.
Ex: we want to make a layout named `authentications`, then we have to make a file in `app/views/layouts/authentications.html.erb` directory.

### Using the new layout

To use the new layout, we have to update the controller with the following code:

```rb
class SomeController < ApplicationController
  layout 'authentications'
end
```

Or we can specify only one action to use the layout with the following code:

```rb
class SomeController < ApplicationController
  layout 'authentications', only: [:new, :create]
end
```

Or we can define a controller function to use the layout with the following code:

```rb
class SomeController < ApplicationController

  def new
    render layout: 'authentications'
  end

end
```

## Setup Tailwind CSS

### Install Tailwind CSS

To install Tailwind CSS, the following command was used:

```bash
bundle add tailwindcss-ruby
bundle add tailwindcss-rails
rails tailwindcss:install
```

### Add Daisy UI (Node dependency)

To add Daisy UI, the following **Node** command can be used:

```bash
npm init -y
npm install daisyui@latest
```

Then the following code was added to the `app/assets/tailwind/application.css` file:

```css
@import "tailwindcss" source(none);
@source "../../../public/*.html";
@source "../../../app/helpers/**/*.rb";
@source "../../../app/javascript/**/*.js";
@source "../../../app/views/**/*";

@plugin "daisyui";
```

### Add Daisy UI (Bundle file)

To add Daisy UI, the following **Ruby** command can be used:

```bash
curl -sLo app/assets/tailwind/daisyui.js https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.js
```

Then the following code was added to the `app/assets/tailwind/application.css` file:

```css
@import "tailwindcss" source(none);
@source "../../../public/*.html";
@source "../../../app/helpers/**/*.rb";
@source "../../../app/javascript/**/*.js";
@source "../../../app/views/**/*";

@plugin "./daisyui.js";
```

## Sidekiq Setup for Background Jobs

### Install Sidekiq

To install Sidekiq, the following command was used:

```bash
bundle add sidekiq
```

### Setup Sidekiq files

To setup Sidekiq, add active job adapter in the `config/application.rb` file:

```rb
config.active_job.queue_adapter = :sidekiq
```

Create a new file `config/initializers/sidekiq.rb` with the following code:

```rb
redis_url = "redis://#{ Rails.application.credentials.redis[:username] }:#{ Rails.application.credentials.redis[:password] }@#{ Rails.application.credentials.redis[:host] }:#{ Rails.application.credentials.redis[:port] }/0" || ENV['REDIS_URL']
redis_timeout= 30

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
```

*In Production, ensure to add the `REDIS_URL` environment variables in the server.*

*OR* We can add the data in the `config/credentials.yml.enc` file.

```yml
redis:
  host: localhost
  port: 6379
  username: username
  password: password
```

Now add a new file `config/sidekiq.yml` with the following code:

```yml
:concurrency: 5
:queues:
  - default
  - mailers
  - some_queue_name
:logfile: log/sidekiq.log
:pidfile: tmp/pids/sidekiq.pid
```

### Impletement Sidekiq in the application

We have to create a new job with the following command:

```bash
rails generate job some_worker
```

Then we have to update the job file with the following code:

```rb
class SomeWorker < ApplicationJob
  queue_as :some_queue_name

  def perform(*args)
    # Do something later
  end
end
```

Then we have to call the job in the `controller` with the following code:

```rb
SomeWorker.perform_later
# OR
SomeWorker.set(wait: 5.minutes).perform_later
# OR
SomeWorker.perform_in(5.minutes)
```

### Start Sidekiq server or add to Procfile

To start Sidekiq, the following command was used:

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

Or add the following code to the `Procfile`:

```yml
web: bundle exec rails server
worker: bundle exec sidekiq -C config/sidekiq.yml
```

### Monitor Sidekiq (Optional)

To monitor Sidekiq, we can add the following routes to the `config/routes.rb` file:

```rb
# sidekiq web UI
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

## Setup Internationalization (I18n)

### Setup the initial configuration

To setup Internationalization, we have to add the following code to the `config/application.rb` file:

```rb
config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
config.i18n.available_locales = [:en, :bn]
config.i18n.default_locale = :en
```

Then we have to add the following code to the `config/locales/en.yml` file:

```yml
en:
  hello: "Hello world"
```

Same way we have to add the following code to the `config/locales/bn.yml` file:

```yml
bn:
  hello: "হ্যালো ওয়ার্ল্ড"
```

Add the following code to the application controller:

```rb
class ApplicationController < ActionController::Base
    around_action :switch_locale

    def switch_locale(&action)
        locale = params[:lang] || session[:lang] || I18n.default_locale
        session[:lang] = locale
        I18n.with_locale(locale, &action)
    end

    # rest of the code
end
```

Then we can use the following code in the views:

```erb
<%= t 'hello' %>
```

### Setup the locale through in the URL

Now we can use the following URL to change the language:

For English: [http://localhost:3000/?lang=en](http://localhost:3000/?lang=en)  
For Bangla: [http://localhost:3000/?lang=bn](http://localhost:3000/?lang=bn)  
  
This will change the language of the site and store the language in the session.
More language can be added in this process.
