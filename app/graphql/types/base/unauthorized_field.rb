module Types::Base
  class UnauthorizedField < Types::Base::Field
    def authorized?(obj, args, ctx)
      true
    end
  end
end