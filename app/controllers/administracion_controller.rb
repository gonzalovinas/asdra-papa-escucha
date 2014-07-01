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

  def alta_nuevo_padre
    render :action => "alta_nuevo_padre", :layout=> false
  end

  def do_alta_nuevo_padre
    pe = PadresEscuchan.new

    pe.apellidos= params[:apellidos]
    pe.nombres  = params[:nombres]
    pe.correo   = params[:correo]
    pe.tipo     = params[:tipo]

    pe.save

    render :json => {
        :status => "OK",
        :data => {
            :id_padre_escucha => pe.r_id
        }
    }, :layout=> false
  end


end
