class Flash

  def initialize(req)
    flash = req.cookies['_rails_lite_flash']
    @now = {}
    @old = flash ? JSON.parse(flash) : {}
    @new = {}
  end

  def []=(key, value)
    @new[key.to_s] = value
  end

  def [](key)
    @now[key.to_s] || @new[key.to_s] || @old[key.to_s]
  end

  def now
    @now
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_flash', { path: "/", value: @new.to_json })
  end
  
end
