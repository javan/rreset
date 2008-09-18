require 'digest/md5'

class Flickr
  AUTH_ENDPOINT = 'http://flickr.com/services/auth/'
  API_ENDPOINT  = 'http://flickr.com/services/rest/'
  API_KEY       = RRESET_CONFIG['flickr']['api_key']
  SECRET        = RRESET_CONFIG['flickr']['secret']
  
  attr_accessor :params, :signed_request, :method
  
  # Raised when there's a problem connecting to Flickr
  class ConnectionError < StandardError
    def initialize(message = "Couldn't connect to Flickr.")
      @message = message
    end
    def to_s; @message ;end
  end
  
  def initialize(options = {})
    options.reverse_merge!(:type => :api, :params => {})
    @params = { :api_key => API_KEY }.merge(options[:params])
    @endpoint = self.class.const_get("#{options[:type].to_s.upcase}_ENDPOINT".to_sym)
    @method = options[:method] || nil
    @signed_request = options[:signed_request] || false
  end
  
  def self.login_url
    self.new(
      :type => :auth,
      :params => { :perms => :read },
      :signed_request => true
    ).send(:build_url)
  end
  
  def self.auth_get_token(frob)
    self.new(
      :method => 'flickr.auth.getToken',
      :params => { :frob => frob },
      :signed_request => true
    ).send(:invoke!)
  end
  
  def self.photosets_get_list(nsid)
    photosets = self.new(
      :method => 'flickr.photosets.getList',
      :params => { :user_id => nsid }
    ).send(:invoke!)[:photosets]
    if photosets
      # Starting with an empty array and then flattening ensures
      # there's an array of photosets even if the user has just 1.
      [photosets[:photoset]].flatten.map(&:symbolize_keys!)
    else
      [] # User has no photosets
    end
  end

  def self.photosets_get_info(photoset_id)
    self.new(
      :method => 'flickr.photosets.getInfo',
      :params => { :photoset_id => photoset_id }
    ).send(:invoke!)[:photoset]
  end
  
  def self.photosets_get_photos(photoset_id)
    total_in_set = photosets_get_info(photoset_id)[:photos].to_i
    per_page = current_reach = 500
    page = 1
    photos = []
    loop do
      photos << self.new(
        :method => 'flickr.photosets.getPhotos',
        :params => { :photoset_id => photoset_id, :media => :photos, :page => page, :per_page => per_page }
      ).send(:invoke!)[:photoset][:photo]
      break if total_in_set <= current_reach
      current_reach += per_page
      page += 1
    end
    photos.flatten.map(&:symbolize_keys!)
  end
  
  def self.photosets_get_context(photo_id, photoset_id)
    self.new(
      :method => 'flickr.photosets.getContext',
      :params => { :photoset_id => photoset_id, :photo_id => photo_id }
    ).send(:invoke!).delete_if { |key, value| value[:id] == '0' }
  end
  
  def self.photos_get_info(photo_id)
    self.new(
      :method => 'flickr.photos.getInfo',
      :params => { :photo_id => photo_id }
    ).send(:invoke!)[:photo]
  end
  
  def self.photos_get_sizes(photo_id)
    self.new(
      :method => 'flickr.photos.getSizes',
      :params => { :photo_id => photo_id }
    ).send(:invoke!)[:sizes][:size].inject({}) { |result, size| result[size['label'].downcase.to_sym] = size.symbolize_keys; result }
  end
  
  def self.photos_licenses_get_info(license = 0)
    # These should change very very rarely, so it gets cached to class var
    @@licenses ||= self.new(
      :method => 'flickr.photos.licenses.getInfo'
    ).send(:invoke!)[:licenses][:license].index_by { |l| l['id'] }.each { |k,v| v.symbolize_keys! }
    @@licenses[license.to_s]
  end
  
private

  def sign_request
    @params.delete(:api_sig)
    @params.merge!(:api_sig => Digest::MD5.hexdigest(SECRET + @params.stringify_keys.sort.flatten.join))
  end
  
  def build_url
    @params[:method] = @method unless @method.nil?
    sign_request if @signed_request
    "#{@endpoint}?" + @params.map { |key, val| "#{key}=#{CGI.escape(val.to_s)}" }.join('&')
  end
  
  def invoke!
    xml = Rails.cache.fetch(build_url) { get(build_url) }
    resp = Hash.from_xml(xml).symbolize_keys! rescue false
    if resp && resp[:rsp] && resp[:rsp][:stat] == 'ok'
      return resp[:rsp]
    else
      raise ConnectionError.new((resp[:rsp][:err][:msg] rescue nil))
    end
  end
  
  def get(url)
    RAILS_DEFAULT_LOGGER.info("Calling #{url}")
    uri = URI.parse(url)
    begin
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.read_timeout = 6 #seconds
        http.get(uri.request_uri)
      end
    rescue Timeout::Error => e
      raise ConnectionError.new(e.message)
    end
    
    handle_response(response)
  end
  
  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      response.body
    else
      raise ConnectionError
    end
  end
end
