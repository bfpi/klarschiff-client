require 'active_resource/base'

module ActiveResource
  class Base
    class << self
      private
      def instantiate_record_with_citysdk_array_path(record, prefix_options = {})
        instantiate_record_without_citysdk_array_path record.is_a?(Array) ? 
          record.first : record, prefix_options
      end

      alias_method_chain :instantiate_record, :citysdk_array_path
    end
  end
end
