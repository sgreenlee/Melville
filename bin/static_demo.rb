require 'rack'
require 'byebug'
require_relative '../lib/exceptions'
require_relative '../lib/static_files'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class FlashController < ControllerBase
  def show

  end

  def set_flash
    flash[:message] = params[:message]
    render_content("Got your message", "text/html")
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/simon$"), FlashController, :show
  get Regexp.new("^/simon/says/(?<message>\\w+)$"), FlashController, :set_flash
end

run_proc = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use StaticFileServer
  use ExceptionHandler
  run run_proc
end

Rack::Server.start(
 app: app,
 Port: 3000
)
