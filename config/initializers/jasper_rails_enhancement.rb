class ActionController::Base
  private
  def jasper_pdf(arg)
    model_name = arg[:model] || "jasper"
    record_name = arg[:record] || "record"
    unless arg[:template].nil?
      jasper_file = File.join("app/views",arg[:template])
      jasper_file += ".jasper" unless jasper_file =~ /.jasper$/
    else
      jasper_file = File.join("app/views",params[:controller],params[:action]) + ".jasper"
    end
    if arg[:resource].size > 0 && arg[:resource][0].kind_of?(Hash)
      resource = JasperSourceBuilder.new(arg[:resource], model_name, record_name)
    else
      resource = arg[:resource]
    end
    jasper_params = arg[:params] || params
    options = arg[:options] || {}
    send_data JasperRails::Jasper::Rails.render_pdf(jasper_file, resource, jasper_params, options), {
                  :type => Mime::PDF,
                  :filename => arg[:filename]
    }
  end
end
