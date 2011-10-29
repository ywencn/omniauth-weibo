require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Weibo < OmniAuth::Strategies::OAuth
      option :name, 'weibo'
      option :sign_in, true
      def initialize(*args)
        super
        # taken from https://github.com/intridea/omniauth/blob/0-3-stable/oa-oauth/lib/omniauth/strategies/oauth/tsina.rb#L15-21
        options.client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_path => '/oauth/authorize',
          :realm => 'OmniAuth',
          :request_token_path => '/oauth/request_token',
          :site => 'http://api.t.sina.com.cn',
        }
      end

      def consumer
        consumer = ::OAuth::Consumer.new(options.consumer_key, options.consumer_secret, options.client_options)
        consumer
      end

      info do
        {
          :nickname => raw_info['screen_name'],
          :name => raw_info['name'],
          :location => raw_info['location'],
          :image => raw_info['profile_image_url'],
          :description => raw_info['description'],
          :urls => {
            'Website' => raw_info['url'],
            'Weibo' => 'http://weibo.com/' + raw_info['id'].to_s,
          }
        }
      end


      #taken from https://github.com/intridea/omniauth/blob/0-3-stable/oa-oauth/lib/omniauth/strategies/oauth/tsina.rb#L52-67
      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => true, 'request_token' => request_token.token, 'request_secret' => request_token.secret}

        if request_token.callback_confirmed?
          redirect request_token.authorize_url(options[:authorize_params])
        else
          redirect request_token.authorize_url(options[:authorize_params].merge(:oauth_callback => callback_url))
        end

      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/account/verify_credentials.json').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end