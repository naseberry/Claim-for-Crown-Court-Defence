module API
  module Entities
    class ExternalUser < API::Entities::User
      expose :email
    end
  end
end
