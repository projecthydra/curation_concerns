source 'https://rubygems.org'

gem 'hydra-head', github:'flyingzumwalt/hydra-head', ref:'89e139f' # Rely on this branch until projecthydra/hydra-head#262 Pull Request is resolved https://github.com/projecthydra/hydra-head/pull/262

# Specify your gem's dependencies in curation_concerns.gemspec
gemspec

gem 'slop', '~> 3.6.0' # This just helps us generate a valid Gemfile.lock when Rails 4.2 is installed (which requires byebug which has a dependency on slop)

gem 'curation_concerns-models', path: './curation_concerns-models'

group :test do
  gem 'simplecov', '~> 0.9', require: false
  gem 'coveralls', require: false
  gem 'poltergeist'
end

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
else
  gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']
  if ENV['RAILS_VERSION'] and ENV['RAILS_VERSION'] !~ /^4.2/
    gem 'sass-rails', "< 5.0"
  else
    gem 'responders', "~> 2.0"
    gem 'sass-rails', ">= 5.0"
  end

  extra_file = File.expand_path("../spec/test_app_templates/Gemfile.extra", __FILE__)
  instance_eval File.read(extra_file)
end
