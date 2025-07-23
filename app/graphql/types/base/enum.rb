module Types::Base
  class Enum < GraphQL::Schema::Enum

    # Override coerce result to call super, but if the value
    # resolves to blank rather than nil as is default, then catch
    # the error and accept it anyway
    class << self
      def coerce_result(value, ctx)
        super
      rescue self::UnresolvedValueError
        return nil if value.blank?

        # Only raise an error if we're not in production,
        # to avoid crashing production completely for bad enum values
        # raise unless Rails.env.production?

        return nil
      end
    end
  end
end
