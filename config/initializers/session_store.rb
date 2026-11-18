# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Name und Pfad des Session-Cookies werden aus relative_url_root abgeleitet, damit mehrere
# Client-Instanzen unter demselben Hostnamen (z.B. / und /ppc) getrennte Sessions erhalten.
module SessionCookie
  KEY_PREFIX = '_klarschiff_client'

  def self.options(relative_url_root)
    path = "/#{relative_url_root.to_s.delete_prefix('/')}".chomp('/').presence || '/'
    suffix = path.delete_prefix('/').parameterize(separator: '_').presence

    { key: [KEY_PREFIX, suffix, 'session'].compact.join('_'), path: }
  end
end

Rails.application.config.session_store :cookie_store,
                                       **SessionCookie.options(Rails.application.config.relative_url_root)
