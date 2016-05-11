require 'byebug'

module ProtectFromForgery

  def generate_authenticity_token
    @authenticity_token ||= SecureRandom::urlsafe_base64
  end

  def store_authenticity_token
    return nil unless @authenticity_token
    @res.set_cookie('_rails_lite_app_auth_token', path: '/', value: @authenticity_token)
  end

  def form_authenticity_token
    <<-HTML
    <input type="hidden" name="authenticity_token" value="#{generate_authenticity_token}">
    HTML
  end
end

class CSRFProtection

  def initialize(app)
    @app = app
  end

  def call(env)
    debugger
    req = Rack::Request.new(env)
    verify_authenticity!(req) unless req.request_method == "GET"
    @app.call(env)
  end


  private

  def verify_authenticity!(req)
    auth_token = req.cookies['_rails_lite_app_auth_token']
    raise 'Form Authenticiy Error' unless auth_token && auth_token == req.params['authenticity_token']
  end
end
