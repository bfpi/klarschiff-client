class Settings
  # Defines accessors for application configuration with values
  # defined in config/settings.yml
  # Each root node becomes an own module to scope the options
  @@config ||= File.open(Rails.root.join('config', 'settings.yml')) { |file|
    YAML::load file
  }.with_indifferent_access.each do |context, options|
    m = Module.new
    client = nil
    #setzen der Client-Parameter in Abhängigkeit des gestarteten Clients, wenn entsprechende Parameter nicht gesetzt wurden
    options.each do |name, value|
      if (context == 'client')
        if name == 'login_required'
          unless value.to_s.in?(%w(true false))
            raise 'Value for param client.login_required in settings.yml has to be one of [true, false]'
          end
          client = value
        else
          value = (/email|abuses|votes|create_comment/ =~ name ? !client : client) if value.to_s.blank?
        end
      end
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end
  
  module Client
    class << self
      def method_missing(name, *args, &block)
        return super unless name.to_s.starts_with?('show_')
        Rails.logger.warn "Missing configuration for key 'client.#{name}' in settings.yml - returning 'false' as default value!"
        false
      end
    end
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
