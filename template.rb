def add_gems
  gem 'rexml', '~> 3.2', '>= 3.2.5' # rspec will throw an exception without it

  gem_group :development, :test do
    gem 'rspec-rails', '~> 5.0', '>= 5.0.2'
    gem 'factory_bot_rails', '~> 6.2'
  end

  gem 'devise', '~> 4.8'
  gem 'bootstrap', '~> 5.1'
  gem 'bootstrap_form', '~> 4.5'
  gem 'sprockets-rails', '~> 3.2', '>= 3.2.2'


  run "bundle install"
end


def devise_setup
  if yes?("Would you like to setup devise? y/n", :green)
    generate "devise:install"
    environment 'config.action_mailer.default_url_options = { host: "localhost", port: 3000 }', env: 'development'
  end
  say

  model_name = ask("What would you like your devise model to be called? [user]", :green)
  model_name = "user" if model_name.blank?
  generate "devise #{model_name}"
  rails_command "db:migrate"
  generate "devise:views"

  say
  say "✅ Devise #{model_name} is created! and View generated", :green
  say
end

def setup_bootstrap
  say "In addition to bootstrap, we setup the boostrap-form gem"
  if yes?("Do want to setup bootstrap? y/n", :green)
    bootstrap_setup
  end
  say
end

def bootstrap_setup
  remove_file "app/assets/stylesheets/application.css"

  file "app/assets/stylesheets/application.scss", <<~EOM
  @import "rails_bootstrap_forms";
  EOM

  file "app/javascript/stylesheets/application.scss", <<~EOM
  @import "bootstrap";

  // bootstrap styling for the flash[:notice] and flash[:alert]
  .alert-notice {
      @extend .alert-success;
    }

  .alert-alert {
    @extend .alert-danger;
  }

  .alert {
    position: relative;
    padding: 1rem 1rem;
    margin-bottom: 0;
    border: 1px solid transparent;
    border-radius: 0px;
  }
  EOM

  run "yarn add @popperjs/core bootstrap"

  add_bootstrap_js = <<~EOM
  import "bootstrap"
  import "../stylesheets/application"
  EOM

  inject_into_file "app/javascript/packs/application.js", "\n#{add_bootstrap_js}", after: 'import "channels"'

  stylesheet_pack_tag = '<%= stylesheet_pack_tag "application", media: "all", "data-turbolinks-track": "reload" %>'

  inject_into_file "app/views/layouts/application.html.erb", "\n\t #{stylesheet_pack_tag}", after: "<%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>"
end


def static_page
  say
  if yes?("Do you want a static welcome page? y/n", :green)
    generate "controller welcome index"
    route "root 'welcome#index'"

    file "app/views/welcome/index.html.erb", <<~EOM
    <div class="container py-4">
      <header class="pb-3 mb-4 border-bottom">
        <a href="/" class="d-flex align-items-center text-dark text-decoration-none">
          <span class="fs-4">GetReady Rails</span>
        </a>
      </header>

      <div class="p-5 mb-4 bg-light rounded-3">
        <div class="container-fluid py-5">
          <h1 class="display-5 fw-bold">Welcome 🤗</h1>
          <p class="col-md-8 fs-4">GetReady rails is a template to jumpstart your rails application. This default page is styled with <a href="https://getbootstrap.com/">Bootstrap 5</a>. The template installed and setup devise, bootstrap, rspec, generate flash message and added this welcome page.</p>
          <button class="btn btn-primary btn-lg" type="button">Example button</button>
        </div>
      </div>

      <div class="row align-items-md-stretch">
        <div class="col-md-6">
          <div class="h-100 p-5 text-white bg-dark rounded-3">
            <h2>Change the background</h2>
            <p>Swap the background-color utility and add a `.text-*` color utility to mix up the jumbotron look. Then, mix and match with additional component themes and more.</p>
            <button class="btn btn-outline-light" type="button">Example button</button>
          </div>
        </div>
        <div class="col-md-6">
          <div class="h-100 p-5 bg-light border rounded-3">
            <h2>Add borders</h2>
            <p>Or, keep it light and add a border for some added definition to the boundaries of your content. Be sure to look under the hood at the source HTML here as we've adjusted the alignment and sizing of both column's content for equal-height.</p>
            <button class="btn btn-outline-secondary" type="button">Example button</button>
          </div>
        </div>
      </div>

      <footer class="pt-3 mt-4 text-muted border-top">
        © 2021
      </footer>
    </div>
    EOM
  end

  say
  say "✅ Static welcome page is generated 🤗", :green
  say
end

def flash_message
  say "Generating flash messages partials in app/views/layouts folder", :blue
  say
  file "app/views/layouts/_flash_messages.html.erb", <<~EOM
    <% flash.each do |key, message| %>
      <div class="text-center alert alert-<%= key %> alert-dismissible fade show" role="alert">
        <strong><%= key == 'notice' ? 'Success!' : 'Error!' %></strong>  <%= message %>
      </div>
    <% end %>
  EOM

  inject_into_file "app/views/layouts/application.html.erb", "\n<%= render 'layouts/flash_messages' %>\n", before: "<%= yield %>"
end

def rspec_setup
  say
  say "Setting up rspec", :blue
  say

  rspec_generators_config = <<-EOM
    config.generators do |g|
      g.test_framework :rspec,
      view_specs: false,
      helper_specs: false,
      routing_specs: false
    end
  EOM

  inject_into_file "config/application.rb", "\n #{rspec_generators_config}", after: "config.load_defaults 6.1"

  generate "rspec:install"
  remove_dir "test"

  say
  say "✅ RSpec installed successfully", :green
  say
  say "Removed rails default test folder", :red
  say
end


def initialize_git
  git :init
  git add: "."
  git commit: %Q{ -m 'Initialize project' }

  say
  say "✅ Git add and git commit your initial project", :green
  say
end

def completion_message
  say "The following tasks were completed:"
  say
  say "Installation and setup of the following gems:", :red
  say "🎊 Devise", :green
  say "🎊 Bootstrap 5", :green
  say "🎊 Bootstrap Form", :green
  say "🎊 RSpec", :green
  say "🎊 Configured RSpec generators", :green
  say "🎊 Generated a welcome controller and set root path", :green
  say "🎊 Added flash messages partial", :green
  say
  say "Start the application and see the default page", :green
  say "Have building your awesome project 🎉", :green
end


after_bundle do
  add_gems
  setup_bootstrap
  flash_message
  static_page
  rspec_setup
  devise_setup
  initialize_git
  completion_message
end


