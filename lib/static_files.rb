require 'mime-types'

class StaticFileServer

  STATIC_DIR_RELATIVE = "../../public"
  STATIC_DIR = File.expand_path(STATIC_DIR_RELATIVE, __FILE__)
  STATIC_FILE_PATTERN = /\.(?<ext>[a-zA-Z0-9]{1,4})$/

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    if ext = file_extension(req.fullpath)
      res = Rack::Response.new
      file_path = File.join(STATIC_DIR, req.fullpath)
      return_file(res, file_path, ext) || return_not_found(res)
      res.finish
    else
      @app.call(env)
    end
  end


  private

  def file_extension(path)
    match = STATIC_FILE_PATTERN.match(path)
    return match[:ext] if match
    nil
  end

  def return_file(res, path, ext)
    return nil unless File::exists?(path)
    mime_type = MIME::Types.type_for(ext).first.content_type
    res['Content-Type'] = mime_type
    res.write(File.read(path))
    res.status = 200
  end

  def return_not_found(res)
    res.status = 404
  end


end
