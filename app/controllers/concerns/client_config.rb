module ClientConfig
  extend ActiveSupport::Concern
  
  def display?(par)
    instance_variable_get(inst = "@show_#{ par }") || 
      instance_variable_set(inst, Settings::Client.send(inst.gsub('@', '')))
  end
end
