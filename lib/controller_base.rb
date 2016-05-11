require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = req.params.merge(params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'already built response' if already_built_response?
    @res['Location'] = url
    persist_cookies
    @res.status = 302
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'response already built' if already_built_response?
    @res['Content-Type'] = content_type
    persist_cookies
    @res.write(content)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = get_template_path(template_name)
    template = File.open(path, 'r').read
    content = ERB.new(template).result(binding)
    render_content(content, 'text/html')
  end

  def get_template_path(template_name)
    controller_name = self.class.name.underscore
    # relative_path = "../../views/#{controller_name}/#{template_name}.html.erb"
    # File.expand_path(relative_path, __FILE__)
    "views/#{controller_name}/#{template_name}.html.erb"
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def persist_cookies
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end
end
