require 'rack'
require 'byebug'
require_relative '../lib/exceptions'
require_relative '../lib/static_files'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class CsrfController < ControllerBase
  def get
  end

  def show
  end
end

router = Router.new
router.draw do
  post Regexp.new("^/$"), CsrfController, :show
  get Regexp.new("^/$"), CsrfController, :get
end

run_proc = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  debugger
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ExceptionHandler
  use CSRFProtection
  use StaticFileServer
  run run_proc
end

Rack::Server.start(
 app: app,
 Port: 3000
)
