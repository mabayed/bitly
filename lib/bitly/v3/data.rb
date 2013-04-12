module Bitly
  module V3
    class Data
      include HTTParty
      base_uri 'https://api-ssl.bitly.com/v3/'

      def initialize(access_token)
        @access_token = access_token
      end


      # Given a search query, use bit.ly's search API:
      # http://dev.bitly.com/data_apis.html#v3_search
      #
      # Returns a list of search results
      def search(search_query, opts={})
        raise BitlyError.new("Access token required", 500) unless opts.include? :access_token 
        opts.reject! {|k, v| ![:limit, :offset, :lang, :cities, :domain, :fields].include? k}

        result = self.class.get("/search", :query => opts.merge({:query => search_query}))

        if result['status_code'] == 200
          return result['data']['results']
        else
          raise BitlyError.new(result['status_txt'], result['status_code'])
        end
      end
    end
  end
end
