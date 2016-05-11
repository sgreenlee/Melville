class Flash

  def initialize(req)
    flash = req.cookies['_rails_lite_flash']
    @now = flash ? JSON.parse(flash) : {}
    @flash = {}
  end

  def []=(key, value)
    @flash[key.to_s] = value
  end

  def [](key)
    @now[key.to_s] || @flash[key.to_s]
  end

  def now
    @now
  end


  def store_flash(res)
    res.set_cookie('_rails_lite_flash', { path: "/", value: @flash.to_json })
  end

end
