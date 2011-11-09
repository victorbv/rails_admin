require 'rails_admin/config/fields/base'
require 'rails_admin/config/fields/types/file_upload'

module RailsAdmin
  module Config
    module Fields
      module Types
        # Field type that supports Paperclip file uploads
        class Dragonfly < RailsAdmin::Config::Fields::Types::FileUpload
          RailsAdmin::Config::Fields::Types.register(self)
          
          def errors
            bindings[:object].errors["#{name}_uid"] + bindings[:object].errors["#{name}_name"]
          end
          
          register_instance_option(:image?) do
            false unless value
            if respond_to?("#{name}_name")
              super(field.send("#{name}_name"))
            else
              true # Dragonfly really is image oriented
            end
          end
          
          register_instance_option(:required?) do
            @required ||= !!abstract_model.model.validators_on("#{name}_uid").find do |v|
              v.is_a?(ActiveModel::Validations::PresenceValidator) && !v.options[:allow_nil]
            end
          end
          
          register_instance_option(:delete_method) do
            "remove_#{name}"
          end
          
          register_instance_option(:cache_method) do
            "retained_#{name}"
          end
          
          register_instance_option(:thumb_method) do
            "100x100>"
          end
          
          def resource_url(thumb = false)
            return nil unless (v = value)
            thumb ? v.thumb(thumb).try(:url) : v.url
          end
        end
      end
    end
  end
end
