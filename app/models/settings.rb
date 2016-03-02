class Settings
  # Defines accessors for application configuration with values
  # defined in config/settings.yml
  # Each root node becomes an own module to scope the options
  @@config ||= File.open(Rails.root.join('config', 'settings.yml')) { |file|
    YAML::load file
  }.with_indifferent_access.each do |context, options|
    m = Module.new
    client = nil
    options.each do |name, value|
      if (context == 'client')
        client = value if name == 'login_required'
        unless (name == 'login_required')
          value = (/email|abuses|votes|create_comment/ =~ name ? !client : client) if value.to_s.blank?
        end
        Rails.logger.debug("#{ name }: #{ value }")
      end
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end

  module Route
    class << self
      delegate :relative_url_root, to: 'Rails.configuration.action_controller'

      def method_missing(method, *arguments, &block)
        if method.to_s =~ /_path$/
          Rails.application.routes.url_helpers.send(method, *arguments).tap do |path|
            if relative_url_root.present?
              path.prepend relative_url_root unless path.start_with?(relative_url_root)
            end
          end
        elsif method.to_s =~ /^path_to_/
          ActionController::Base.helpers.send method, *arguments
        else
          super
        end
      end
    end
  end
end
