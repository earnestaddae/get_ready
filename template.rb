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

  say
  say "Styling devise forms for [registration, login and edit]", :green
  say

  devise_registration_form
  devise_login_form
  devise_edit_form
  devise_password_form
end

def devise_registration_form
  remove_file "app/views/devise/registrations/new.html.erb"
  registration = <<~EOM
  <div class="container mt-4 mb-4">
    <h2>Sign up</h2>

    <%= bootstrap_form_for(resource, as: resource_name, url: registration_path(resource_name), label_errors: true) do |f| %>

        <%= f.email_field :email, autofocus: true, autocomplete: "email" %>
        <%= f.password_field :password, autocomplete: "new-password" %>
        <% if @minimum_password_length %>
        <em>(<%= @minimum_password_length %> characters minimum)</em>
        <% end %>

        <%= f.password_field :password_confirmation, autocomplete: "new-password" %>

        <div class="mt-4"></div>

        <%= f.submit "Sign up", class: "btn btn-success" %>
    <% end %>

    <div class="mt-3"></div>
    <%= render "devise/shared/links" %>
  </div>
  EOM
  file "app/views/devise/registrations/new.html.erb", "#{registration}"
end

def devise_login_form
  remove_file "app/views/devise/sessions/new.html.erb"
  login = <<~EOM
  <div class="container mt-4 mb-4">
    <h2>Log in</h2>

    <%= bootstrap_form_for(resource, as: resource_name, url: session_path(resource_name), label_errors: true) do |f| %>

      <%= f.email_field :email, autofocus: true, autocomplete: "email" %>

      <%= f.password_field :password, autocomplete: "current-password" %>

      <% if devise_mapping.rememberable? %>
        <%= f.check_box :remember_me %>
      <% end %>

      <div class="mt-4"></div>

      <%= f.submit "Log in", class: "btn btn-success" %>
    <% end %>

    <div class="mt-3"></div>
    <%= render "devise/shared/links" %>
  </div>
  EOM

  file "app/views/devise/sessions/new.html.erb", "#{login}"
end

def devise_edit_form
  remove_file "app/views/devise/registrations/edit.html.erb"

  edit = <<~EOM
  <div class="container mt-4 mb-4">
    <h2>Edit <%= resource_name.to_s.humanize %></h2>

    <%= bootstrap_form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }, label_errors: true) do |f| %>

      <%= f.email_field :email, autofocus: true, autocomplete: "email" %>

      <% if devise_mapping.confirmable? && resource.pending_reconfirmation? %>
        <div>Currently waiting confirmation for: <%= resource.unconfirmed_email %></div>
      <% end %>


      <%= f.password_field :password, autocomplete: "new-password" %>
      <i>(leave blank if you don't want to change it)</i>
      <% if @minimum_password_length %>
        <br />
        <em><%= @minimum_password_length %> characters minimum</em>
      <% end %>

      <%= f.password_field :password_confirmation, autocomplete: "new-password" %>

        <%= f.password_field :current_password, autocomplete: "current-password" %>
        <i>(we need your current password to confirm your changes)</i>

      <div class="mt-4 mb-3 actions">
        <%= f.submit "Update", class: "btn btn-success" %>
      </div>
    <% end %>

    <h4>Cancel my account</h4>

    <p>Unhappy? <%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete, class: "btn btn-danger btn-sm" %></p>

    <div class="mt-3"></div>
    <%= link_to "Back", :back %>
  </div>
  EOM

  file "app/views/devise/registrations/edit.html.erb", "#{edit}"
end

def devise_password_form
  remove_file "app/views/devise/passwords/new.html.erb"
  password = <<~EOM
  <div class="container mt-4 mb-4">
    <h2>Forgot your password?</h2>

    <%= bootstrap_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f| %>
        <%= f.email_field :email, autofocus: true, autocomplete: "email" %>
        <div class="mt-4"></div>
        <%= f.submit "Send me reset password instructions", class: "btn btn-success" %>
    <% end %>
    <div class="mt-3"></div>
    <%= render "devise/shared/links" %>
  </div>
  EOM
  file "app/views/devise/passwords/new.html.erb", "#{password}"
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

    remove_file "app/views/welcome/index.html.erb"

    file "app/views/welcome/index.html.erb", <<~EOM
    <div class="container py-4">
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

def navbar
  say "Generating navbar partial in app/views/layouts folder", :blue
  say
  file "app/views/layouts/_navbar.html.erb", <<~EOM
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
      <a class="navbar-brand" href="/">GetReady Rails</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <% unless user_signed_in? %>
            <li class="nav-item">
              <%= link_to "Register", new_user_registration_path, class: "nav-link", aria: {current: "page"}  %>
            </li>
            <li class="nav-item">
              <%= link_to "Login", new_user_session_path, class: "nav-link" %>
            </li>
          <% end %>
          <% if user_signed_in? %>
            <li class="nav-item">
              <%= link_to "Edit", edit_user_registration_path, class: "nav-link", aria: {current: "page"}  %>
            </li>
            <li class="nav-item">
              <%= link_to "Logout", destroy_user_session_path, method: :delete, class: "nav-link" %>
            </li>
          <% end %>
        </ul>
        <form class="d-flex">
          <input class="form-control me-2" type="search" placeholder="Search" aria-label="Search">
          <button class="btn btn-outline-success" type="submit">Search</button>
        </form>
      </div>
    </div>
  </nav>
  EOM

  inject_into_file "app/views/layouts/application.html.erb", "\n\t <%= render 'layouts/navbar' %>\n", after: "<body>"
end

def flash_message
  say "Generating flash messages partial in app/views/layouts folder", :blue
  say
  file "app/views/layouts/_flash_messages.html.erb", <<~EOM
    <% flash.each do |key, message| %>
      <div class="text-center alert alert-<%= key %> alert-dismissible fade show rounded" role="alert">
        <strong><%= key == 'notice' ? 'Success!' : 'Error!' %></strong>  <%= message %>
      </div>
    <% end %>
  EOM

  inject_into_file "app/views/layouts/application.html.erb", "\n\t <%= render 'layouts/flash_messages' %>\n", after: "<%= render 'layouts/navbar' %>"
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
  navbar
  flash_message
  static_page
  rspec_setup
  devise_setup
  initialize_git
  completion_message
end


