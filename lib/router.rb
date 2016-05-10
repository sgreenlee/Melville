require 'byebug'

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @method = http_method.to_s.upcase
    @controller = controller_class
    @action = action_name.to_s.to_sym
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    # debugger
    req.request_method == @method && req.fullpath =~ @pattern
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    params = build_params(req)
    controller = @controller.new(req, res, params)
    controller.invoke_action(@action)
  end

  private

  def build_params(req)
    params = {}
    match = @pattern.match(req.fullpath)
    # debugger
    @pattern.named_captures.each do |name, positions|
      positions.each do |position|
        params[name.to_sym] = match[position]
      end
    end
    params
  end

end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    idx = @routes.index { |route| route.matches?(req) }
    @routes[idx] if idx
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end

end
