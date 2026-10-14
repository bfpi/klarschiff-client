# frozen_string_literal: true

class Settings
  # Defines accessors for application configuration with values
  # defined in config/settings.yml
  # Each root node becomes an own module to scope the options
  (@config ||= Config.for(:settings)).with_indifferent_access.each do |context, options|
    m = Module.new
    client = nil
    # setzen der Client-Parameter in Abhängigkeit des gestarteten Clients,
    # wenn entsprechende Parameter nicht gesetzt wurden
    options.each do |name, value|
      if context == 'client'
        if name == 'login_required'
          unless value.to_s.in?(%w[true false])
            raise 'Value for param client.login_required in settings.yml has to be one of [true, false]'
          end

          client = value
        elsif value.to_s.blank?
          value = (/email|abuses|completions|votes|create_comment/.match?(name) ? !client : client)
        end
      end
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end

  module Client
    class << self
      def method_missing(name, *args, &)
        return super unless name.to_s.starts_with?('show_')

        Rails.logger.warn "Missing configuration for key 'client.#{name}' in settings.yml - " \
                          "returning 'false' as default value!"
        false
      end

      def respond_to_missing?(name, include_private = false)
        name.to_s.starts_with?('show_') || super
      end
    end
  end

  module Route
    class << self
      delegate :relative_url_root, to: 'Rails.configuration.action_controller'

      def method_missing(method, *, &)
        if url_helper?(method)
          with_relative_url_root(Rails.application.routes.url_helpers.send(method, *))
        elsif asset_helper?(method)
          ActionController::Base.helpers.send(method, *)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        url_helper?(method) || asset_helper?(method) || super
      end

      private

      def url_helper?(method)
        method.end_with?('_path') && Rails.application.routes.url_helpers.respond_to?(method)
      end

      def asset_helper?(method)
        method.start_with?('path_to_') && ActionController::Base.helpers.respond_to?(method)
      end

      def with_relative_url_root(path)
        return path if relative_url_root.blank? || path.start_with?(relative_url_root)

        "#{relative_url_root}#{path}"
      end
    end
  end
end
