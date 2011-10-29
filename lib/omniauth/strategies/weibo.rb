require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Weibo < OmniAuth::Strategies::OAuth
      option :name, 'weibo'
      option :client_options, {:site => 'http://api.t.sina.com.cn' }
      # option :sign_in, true
      # option :force_sign_in, false

      def initialize(*args)
        super
        options.client_options[:authorize_path] = '/oauth/authenticate' if options.sign_in?
        options.authorize_params[:force_sign_in] = 'true' if options.force_sign_in?
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

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/account/verify_credentials.json').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end