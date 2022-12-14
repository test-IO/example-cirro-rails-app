require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ExampleCirroRailsApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Prevent sassc-rails from setting sass as the compressor
    # Libsass is deprecated and doesn't support modern CSS syntax used by TailwindCSS
    config.assets.css_compressor = nil

    config.generators.test_framework = :rspec

    # Rails 7 defaults to libvips as the variant processor
    # libvips is up to 10x faster and consumes 1/10th the memory of imagemagick
    # If you need to use imagemagick, uncomment this to switch
    # config.active_storage_variant_processor = :mini_magick
    config.active_record.async_query_executor = :global_thread_pool
    config.after_initialize do
      ActionText::ContentHelper.allowed_attributes.add "style"
      ActionText::ContentHelper.allowed_attributes.add "controls"
      ActionText::ContentHelper.allowed_attributes.add "poster"

      ActionText::ContentHelper.allowed_tags.add "video"
      ActionText::ContentHelper.allowed_tags.add "source"
    end
  end
end
