module Panoramic
  module Orm
    module ActiveRecord
      def store_templates
        class_eval do
          validates :body,    :presence => true
          validates :path,    :presence => true
          validates :format,  :inclusion => Mime::SET.symbols.map(&:to_s)
          validates :locale,  :inclusion => I18n.available_locales.map(&:to_s)
          validates :handler, :inclusion => ActionView::Template::Handlers.extensions.map(&:to_s)

          after_save :clear_view_cache

          def clear_view_cache
            Rails.cache.write("panoramic_stored_template_last_updated", Time.now.utc)
            Panoramic::Resolver.instance.clear_cache
          end

          extend ClassMethods
        end
      end

      module ClassMethods
        def find_model_templates(conditions = {})
          self.where(conditions)
        end

        def resolver
          Panoramic::Resolver.using self
        end
      end
    end
  end
end

ActiveRecord::Base.extend Panoramic::Orm::ActiveRecord
