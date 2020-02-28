module Bitly
  module V4
    def self.new(access_token)
      Bitly::V4::Client.new(access_token)
    end
  end
end