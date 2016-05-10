require 'rack'
require 'byebug'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class FlashController < ControllerBase
  def get_flash
    # debugger
    render_content("#{flash[:message]}", "text/html")
  end

  def set_flash
    flash[:message] = params[:message]
    render_content("Got your message", "text/html")
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/simon$"), FlashController, :get_flash
  get Regexp.new("^/simon/says/(?<message>\\w+)$"), FlashController, :set_flash
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
