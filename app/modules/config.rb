module Config
  class << self
    def for(key, env: Rails.env || :development)
      return load_without_env key if env.nil?
      load_for_env key, env
    end

    private

    def config_path
      Rails.application.config.paths['config'].existent.first
    end

    def load_for_env(key, env)
      default = Rails.application.config_for(file_for_key(key, sample: true), env: env).with_indifferent_access
      return default unless (yaml = file_for_key(key)).exist?
      local = Rails.application.config_for(yaml, env: env)
      return default unless local
      default.deep_merge local.with_indifferent_access
    end

    def load_without_env(key)
      default = YAML.safe_load(File.new(file_for_key(key, sample: true))).with_indifferent_access
      return default unless (yaml = file_for_key(key)).exist?
      local = YAML.safe_load(File.new(yaml)).with_indifferent_access
      default.deep_merge local
    end

    def file_for_key(key, sample: false)
      Pathname.new "#{config_path}/#{key}#{'.sample' if sample}.yml"
    end
  end
end
