module Types::Base
  class EnumTranslation < Types::Base::Object
    description "Translate additional fields for EnumerateIt enums"
    field :id, String, null: true, hash_key: :value
    field :name, String, null: true
    field :description, String, null: true
  end
end
