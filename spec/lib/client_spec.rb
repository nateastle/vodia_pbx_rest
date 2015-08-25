require_relative '../spec_helper'

describe VodiaPbxRest::Client do
  before do
    @client = VodiaPbxRest::Client.new('http://mypbxbox.com')
  end

  it '#convert_to_md5 converts password to md5 hash' do
    expect(@client.convert_to_md5('password')).to eq('5f4dcc3b5aa765d61d8327deb882cf99')
  end

  describe '#login' do
    it 'returns a session id' do
      stub_request(:put, "http://mypbxbox.com/rest/system/session").
         to_return(:status => 200, :body => "\"g7lsrphhrkim1jkvbt88\"", :headers => { 'Content-Type' => 'application/json' })
      @client.login('username', 'password')
      expect(@client.session_key).to eq('g7lsrphhrkim1jkvbt88')
    end
  end

  describe "#license" do
    it 'returns a License object' do
      ret = '{
        "agreement": "20130614",
        "company": "",
        "expires": "Active subscription",
        "hosted": true,
        "key": "5V8BC7ABQ609",
        "licensed": true,
        "name": "Vodia PBX Hosted (My Server) 5V8-BC7-ABQ-609",
        "remaining": "59",
        "status": "",
        "type": "color",
        "usage": " Domains: 41/1000, Calls: 5/200, G729A: 200, Extensions: 232/10000, Attendants: 43/10000, Callingcards: 4/10000, Hunt Groups: 65/10000, Paging Groups: 4/10000, Service Flags: 25/10000, IVR Nodes: 14/10000, Agent Groups: 7/10000, Conference Rooms: 6/10000, CO Lines: 13/10000, Adhoc Recording, CSTA, Lync Connectivity, WebRTC support, Barge, Listen, Whisper, Trunk Accounting, Prepaid, Automatic Recording, Fax2Email"
      }'
      stub_request(:get, "http://mypbxbox.com/rest/system/license").
         to_return(:status => 200, :body => ret, :headers => { 'Content-Type' => 'application/json' })
      license = @client.license
      expect(license.agreement).to eq('20130614')
      expect(license.licensed).to be_truthy
    end
  end
end