class Settings
  # Defines accessors for application configuration with values
  # defined in config/settings.yml
  # Each root node becomes an own module to scope the options
  @@config ||= File.open(Rails.root.join('config', 'settings.yml')) { |file|
    YAML::load file
  }.with_indifferent_access.each do |context, options|
    m = Module.new
    options.each do |name, value|
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end

  module Route
    class << self
      delegate :relative_url_root, to: 'Rails.configuration.action_controller'

      def method_missing(method, *arguments, &block)
        if method.to_sym == :assets_path
          "#{ relative_url_root }/assets"
        elsif method.to_s =~ /.*_path$/
          Rails.application.routes.url_helpers.send(method, *arguments).tap do |path|
            if relative_url_root.present?
              path.prepend relative_url_root unless path.start_with?(relative_url_root)
            end
          end
        else
          super
        end
      end
    end
  end
end
