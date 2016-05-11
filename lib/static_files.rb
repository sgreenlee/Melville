require 'mime-types'

class StaticFileServer

  STATIC_DIR = "../../public"

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    static_file_pattern = /\.(?<ext>[a-zA-Z0-9]{1,4})$/
    match = static_file_pattern.match(req.fullpath)
    if match
      res = Rack::Response.new
      file_ext = match[:ext]
      mime_type = MIME::Types.type_for(file_ext).first.content_type
      public_dir = File.expand_path(STATIC_DIR, __FILE__)
      file_path = File.join(public_dir, req.fullpath)
      if File::exists?(file_path)
        res['Content-Type'] = mime_type
        res.write(File.read(file_path))
        res.status = 200
      else
        res.status = 404
      end
      res.finish
    else
      @app.call(env)
    end
  end
end
