class AdministracionController < ApplicationController

  def mensaje_novedad
    render :action => "alta_nuevo_mensaje_novedad", :layout=> false
  end

  def do_alta_nuevo_mensaje_novedad
    mn = MensajesNovedades.new

    mn.fecha = Time.now.strftime("%d-%m-%Y %H:%M")
    mn.mensaje = params[:mensaje_novedad]

    mn.save

    render :json => {:status => "OK"}, :layout=> false
  end

end
