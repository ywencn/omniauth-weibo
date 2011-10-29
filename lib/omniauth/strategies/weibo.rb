require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Weibo < OmniAuth::Strategies::OAuth
      option :name, 'weibo'
      option :sign_in, true
      def initialize(*args)
        super
      end

      def consumer
        consumer = ::OAuth::Consumer.new(options.consumer_key, options.consumer_secret, {:site => 'http://api.t.sina.com.cn', :authorize_path => '/oauth/authorize' })
        consumer.http.open_timeout = options.open_timeout if options.open_timeout
        consumer.http.read_timeout = options.read_timeout if options.read_timeout
        consumer
      end

      uid { access_token.params[:id] }

      info do
        {
          :nickname => raw_info['screen_name'],
          :name => raw_info['name'],
          :location => raw_info['location'],
          :image => raw_info['profile_image_url'],
          :description => raw_info['description'],
          :urls => {
            'Website' => raw_info['url'],
            'Weibo' => 'http://weibo.com/' + raw_info['id'],
          }
        }
      end

      extra do
        { :raw_info => raw_info }
      end
      
      def callback_phase
        raise OmniAuth::NoSessionError.new("Session Expired") if session['oauth'].nil?

        request_token = ::OAuth::RequestToken.new(consumer, session['oauth'][name.to_s].delete('request_token'), session['oauth'][name.to_s].delete('request_secret'))

        opts = {}
        opts[:oauth_verifier] = request['oauth_verifier']

        @access_token = request_token.get_access_token(opts)
        super
      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      rescue ::OAuth::Unauthorized => e
        fail!(:invalid_credentials, e)
      rescue ::NoMethodError, ::MultiJson::DecodeError => e
        fail!(:invalid_response, e)
      rescue ::OmniAuth::NoSessionError => e
        fail!(:session_expired, e)
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/account/verify_credentials.json').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end