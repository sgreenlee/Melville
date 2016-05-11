require 'byebug'
require 'erb'

class ExceptionHandler

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue => e
    debugger
    template_path = File.expand_path("../exception.html.erb", __FILE__)
    exception_template = File.read(template_path)
    result = ERB.new(exception_template).result(binding)
    res = Rack::Response.new
    res.status = 501
    res.write(result)
    res
  end

end
