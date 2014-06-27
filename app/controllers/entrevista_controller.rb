class EntrevistaController < ApplicationController

  def index
  end


  def alta_nueva_entrevista
    render :action => "alta_nueva_entrevista", :layout=> false
  end

  def do_alta_nueva_entrevista

    ne = Entrevista.new

    ne.fecha_llamada    = params[:fecha_llamada]
    ne.fecha_entrevista = params[:fecha_llamada]
    ne.lugar            = params[:lugar]
    ne.mama_escucha     = params[:mama_escucha]

    ne.papa_escucha     = params[:papa_escucha]
    ne.como_supo        = params[:como_supo]
    ne.papa_nombre_apellido = params[:papa_nombre_apellido]
    ne.papa_edad        = params[:papa_edad]
    ne.papa_ocupacion   = params[:papa_ocupacion]
    ne.papa_domicilio   = params[:papa_domicilio]
    ne.papa_telefonos   = params[:papa_telefonos]
    ne.papa_correo      = params[:papa_correo]
    ne.mama_nombre_apellido = params[:mama_nombre_apellido]
    ne.mama_edad        = params[:mama_edad]
    ne.mama_ocupacion   = params[:mama_ocupacion]
    ne.mama_domicilio   = params[:mama_domicilio]
    ne.mama_telefonos   = params[:mama_telefonos]
    ne.mama_correo      = params[:mama_correo]
    ne.sexo             = params[:sexo][0].upcase
    ne.fecha_nacimiento = params[:fecha_nacimiento]
    ne.institucion_nacimiento = params[:institucion_nacimiento]
    ne.observacion_institucion= params[:observacion_institucion]
    ne.meses_nacimiento = params[:meses_nacimiento]
    ne.parto_normal     = params[:parto_normal]? 'S' : 'N'
    ne.sabia_sdown      = params[:sabia_sdown]? 'S' : 'N'
    ne.recepcion_flia   = params[:recepcion_flia]
    ne.patologia_agregada = params[:patologia_agregada]
    ne.observaciones    = params[:observaciones]

    ne.save

    render :json => {:status => "OK"}, :layout=> false
  end

  def buscar_entrevistas
    render :action => "buscar_entrevistas", :layout=> false
  end

  def do_buscar_entrevistas
    r = Entrevista.all.pluck(
        :fecha_entrevista,
        :fecha_llamada,
        :lugar,
        :mama_escucha,
        :papa_escucha,
        :como_supo,
        :papa_nombre_apellido,
        :papa_edad,
        :papa_ocupacion,
        :papa_telefonos,
        :papa_correo,
        :mama_nombre_apellido,
        :mama_edad,
        :mama_ocupacion,
        :mama_domicilio,
        :mama_telefonos,
        :mama_correo,
        :sexo,
        :fecha_nacimiento,
        :institucion_nacimiento,
        :observacion_institucion,
        :meses_nacimiento,
        :parto_normal,
        :sabia_sdown,
        :recepcion_flia,
        :patologia_agregada,
        :observaciones
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
end
