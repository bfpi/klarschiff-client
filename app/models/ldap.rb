class Ldap
  def self.config
    @@config ||= YAML.load(File.new(File.join(
      Rails.root, "config", "ldap.yml"
    )))[Rails.env].with_indifferent_access
  end

  def self.login(username, pwd)
    ldap = Net::LDAP.new(config.slice(:host, :port, :encryption))
    ldap.auth "cn=#{ username },#{ config[:base] }", pwd
    if ldap.bind && (
        user = ldap.search(config.slice(:base).merge(filter: "cn=#{ username }")).try(:first))
      return User.new(name: user.displayname.first, email: user.mail.first)
    end
  end

  def self.login2(name)
    ldap = Net::LDAP.new(config.slice(:host, :port, :encryption))
    ldap.auth *config.slice(:username, :password).values
    if ldap.bind && (
        user = ldap.search(config.slice(:base).merge(filter: "displayname=#{ name }")).try(:first))
      return User.new(name: user.displayname.first, email: user.mail.first)
    end
  end
end
