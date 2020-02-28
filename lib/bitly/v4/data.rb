module Bitly
  module V4
    class Data
      include HTTParty

      base_uri 'https://api-ssl.bitly.com/v4/'

      def initialize(access_token=nil)
        @access_token = access_token
      end


      def highvalue(opts={})
        check_access_token(opts)
        sanitize_opts(opts, [:limit])
        get_response('/highvalue', opts, 'values')
      end


      # Given a search query, use bit.ly's search API:
      # http://dev.bitly.com/data_apis.html#v4_search
      #
      # Returns a list of search results
      def search(search_query, opts={})
        check_access_token(opts)
        sanitize_opts(opts, [:limit, :offset, :lang, :cities, :domain, :fields])
        get_response('/search', opts.merge({:query => search_query}), 'results')
      end


      def bursting_phrases(opts={})
        check_access_token(opts)
        sanitize_opts(opts)
        get_response('/realtime/bursting_phrases', opts)
      end


      def hot_phrases(opts={})
        check_access_token(opts)
        sanitize_opts(opts)
        get_response('/realtime/hot_phrases', opts)
      end


      def clickrate(phrase, opts={})
        check_access_token(opts)
        sanitize_opts(opts)
        get_response('/realtime/clickrate', opts.merge({:phrase => phrase}))
      end


      def link_info(link, opts={})
        link_endpoint(link, opts, 'info', [:content_type])
      end

      def link_content(link, opts={})
        link_endpoint(link, opts, 'content', [:content_type])
      end

      def link_category(link, opts={})
        link_endpoint(link, opts, 'category')
      end

      def link_social(link, opts={})
        link_endpoint(link, opts, 'social')
      end

      def link_location(link, opts={})
        link_endpoint(link, opts, 'location')
      end

      def link_language(link, opts={})
        link_endpoint(link, opts, 'language')
      end


      private
        def link_endpoint(link, opts, endpoint, whitelisted_opts=[])
          check_access_token(opts)
          sanitize_opts(opts, whitelisted_opts)
          get_response("/link/#{endpoint}", opts.merge({:link => link}))
        end

        def check_access_token(opts)
          opts[:access_token] = @access_token unless opts.include?(:access_token) || @access_token.nil?
          raise BitlyError.new("Access token required", 500) unless opts.include? :access_token 
        end

        def sanitize_opts(opts, whitelisted_opts=[])
          whitelisted_opts << :access_token 
          opts.reject! {|k, v| !whitelisted_opts.include? k}
        end

        def get_response(endpoint, opts, result_key=nil)
          result = self.class.get(endpoint, :query => opts)

          if result['status_code'] == 200
            if result_key.nil?
              result['data']
            else
              result['data'][result_key]
            end
          else
            raise BitlyError.new(result['status_txt'], result['status_code'])
          end
        end
    end
  end
end
