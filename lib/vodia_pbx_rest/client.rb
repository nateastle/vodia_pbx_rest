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
      url = "#{@base_url}/audio.wav?type=recording&id=#{media_id} "
      response = RestClient.get url, { :Cookie => "session=#{session_key};ui_reg_gen=block; acct_table#pageNavPos=1;"}
      return response.body
    end

    def accounts(domain)

      RestClient.log = 'stdout'
      response = RestClient.put "#{@base_url}/rest/system/session" , "{\"name\":\"domain\",\"value\":\"#{domain}\"}" , { :Cookie => "session=#{session_key};ui_reg_gen=block; acct_table#pageNavPos=1;"}
      url = "#{@base_url}/dom_accounts.htm?view_type="
      response = RestClient.get url, { :Cookie => "session=#{session_key}; acct_table#pageNavPos=1; ui_dom_other=block",
                                       "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
                                       "Accept-Encoding" => "gzip, deflate",
                                       "Accept-Language" => "en-US,en;q=0.8,pt;q=0.6",
                                       "Connection" => "keep-alive",
                                       "Host" => @base_url,
                                       "Referer" => "#{@base_url}/dom_accounts.htm",
                                       "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36"}
      ret = response.body.match(/users \=(.*?)var footnotes/m)[1].gsub(";","").gsub!("'", "").gsub!(/\"/, "\"")
      return JSON.parse(ret)
    end
  end
end
