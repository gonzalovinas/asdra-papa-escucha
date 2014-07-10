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

  def buscar_padres
    render :action => "buscar_padres", :layout=> false
  end

  def eliminar_padres
    ids = params[:ids]

    ids.each do | id |
      p = PadresEscuchan.find Integer(id)
      p.vigente = "N"
      p.save
    end

    render :json => {
        :status => "OK",
        :data => nil
        }, :layout=> false
  end

  def do_buscar_padres
    filter = ""
    if !params[:query].empty?
      filter = "AND #{params[:qtype]} like '%#{params[:query]}%'"
    end
    r = PadresEscuchan.where("vigente IS NULL #{filter}").order("r_ID DESC").all.pluck(
        :r_id,
        :apellidos,
        :nombres,
        :correo,
        :tipo
    )

    return_data = {}

    return_data[:page] = 1

    return_data[:total] = r.size

    r2 = []

    r.each do | e |
      r2  << {:cell=>e}
    end

    return_data[:rows] = r2

    render :json => return_data, :layout=> false

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

  def configuracion

    @mantenimientos = Mantenimientos.select(:plan, :descripcion_corta, :descripcion_larga)

    render :action => "configuracion", :layout=> false
  end


end
