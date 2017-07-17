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

    def domaininfo
      url = "#{@base_url}/rest/system/domaininfo"
      response = RestClient.get url, { :Cookie => "session=#{session_key}"}
      return JSON.parse(response.body)
    end

    def list_call_recording
      url = "#{@base_url}/rest/domain/1wiresnom.1wi.co/recs"
      response = RestClient.get url, { :Cookie => "session=#{session_key}"}
      return JSON.parse(response.body)
    end

    def get_call_recording(media_id)
      url = "#{@base_url}/audio.wav?type=recording&id=#{media_id}"
      response = RestClient.get url, { :Cookie => "session=#{session_key};ui_reg_gen=block; acct_table#pageNavPos=1;"}
      return response.body
    end

    def accounts(domain)
      RestClient.log = 'stdout'
      url = "#{@base_url}/rest/domain/#{domain}/userlist"
      response = RestClient.get url, { :Cookie => "session=#{session_key};ui_reg_gen=block; acct_table#pageNavPos=1;"}
      return JSON.parse(response.body)
    end

    def acds(domain)
      url = "#{@base_url}/rest/domain/#{domain}/userlist/acds"
      response = RestClient.get url, { :Cookie => "session=#{session_key};ui_reg_gen=block; acct_table#pageNavPos=1;"}
      return JSON.parse(response.body)
    end

    def user_settings(domain, name)
      RestClient.log = 'stdout'
      url = "#{@base_url}/rest/domain/#{domain}/user_settings/#{name}"
      response = RestClient.get url, { :Cookie => "session=#{session_key};ui_reg_gen=block; acct_table#pageNavPos=1;"}
      return JSON.parse(response.body)
    end
  end
end
