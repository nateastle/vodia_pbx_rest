require 'digest'
require 'rest-client'

module VodiaPbxRest
  class License < OpenStruct; end

  class Client
    attr_accessor :username, :password, :base_url, :session_key

    def initialize(base_url)
      @base_url = base_url
    end

    def convert_to_md5(str)
      md5 = Digest::MD5.new
      md5.update str
      md5.hexdigest
    end

    # PUT /rest/system/session
    def login(un, pw)
      @username = un
      @password = convert_to_md5(pw)
      url = "#{@base_url}/rest/system/session"
      data = {
        name: 'auth',
        value: "#{username} #{password}"
      }
      response = RestClient.put url, data.to_json, :content_type => :json, :accept => :json
      @session_key = response.body.gsub(/\"/, '')
      @session_key
    end

    # GET /rest/system/license
    def license
      url = "#{@base_url}/rest/system/license"
      response = RestClient.get url, { :Cookie => "session=#{session_key}"}
      return License.new(JSON.parse(response.body))
    end
  end
end