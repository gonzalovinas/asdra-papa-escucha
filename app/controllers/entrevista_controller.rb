require 'net/smtp'

class EntrevistaController < ApplicationController

  def index
  end

  def entrevistas_pdf
    id = Integer(params[:ids_entrevistas])

    r = Entrevista.where("entrevistas.r_id = #{id}")
    .joins('INNER JOIN entrevistas_estados ee on ee.r_id = entrevistas.id_estado')
    .joins('LEFT JOIN padres_escuchan peP on peP.r_id = entrevistas.id_papa_escucha')
    .joins('LEFT JOIN padres_escuchan peM on peM.r_id = entrevistas.id_mama_escucha')
    .joins('LEFT JOIN entrevistas_ubicaciones eu on eu.r_id = entrevistas.id_ubicacion')
    .all.select(
        'entrevistas.r_id as identificador',
        :fecha_entrevista,
        :fecha_llamada,
        :lugar,
        :papa_telefonos,
        :papa_domicilio,
        :papa_nombre_apellido,
        :mama_telefonos,
        :mama_domicilio,
        :mama_nombre_apellido,
        :nombres,
        'ee.descripcion as descripcion_estado',
        "peP.apellidos || ' ' || peP.nombres as papa_escucha", # TODO: PAPE-28
        "peM.apellidos || ' ' || peM.nombres as mama_escucha", # TODO: PAPE-28
        'eu.descripcion as descripcion_ubicacion',
        :fecha_nacimiento,
        :como_supo,
        :papa_edad,
        :papa_ocupacion,
        :papa_correo,
        :mama_edad,
        :mama_ocupacion,
        :mama_correo,
        :sexo,
        :institucion_nacimiento,
        :observacion_institucion,
        :meses_nacimiento,
        :parto_normal,
        :sabia_sdown,
        :recepcion_flia,
        :patologia_agregada,
        :observaciones,
        :hermanos_json,
        :cobertura_medica,
        'peP.zona as zona_papa',
        'peM.zona as zona_mama',
        'peP.telefonos_sms as telefonos_sms_papa',
        'peM.telefonos_sms as telefonos_sms_mama'
    )

    r_pdf = [r[0].attributes]

    master_ds = JasperSourceBuilder.new(r_pdf, "entrevistas", "entrevista")

    hermanos = [{:hno=>"gonzalo"}]

    slave_ds = JasperSourceBuilder.new(hermanos, "entrevista_hermanos", "hermano")

    master_ds.add_subreport(slave_ds)

    jasper_pdf :resource => master_ds,
               :template => 'reports/entrevista',
               :model    => 'entrevistas',
               :record   => 'entrevista',
               :filename => "ENTREVISTA_N#{id}_#{Time.now.strftime("%Y%m%d")}.pdf"
  end

  def notificar
    count = Entrevista.where("vigente is null and id_papa_escucha is null and id_mama_escucha is null").count("r_id")
    logger.debug "* * * * cantidad entrevistas sin asignar #{count}"
    
    if count > 0 
        r = PadresEscuchan.where("VIGENTE is null").all.pluck(
            "apellidos || ' ' || nombres",
            :correo);
        r.each do | papa |
            enviar_correo_notificar_entrevistas_sin_asignar "#{papa[0]}", papa[1]        
        end
    end
    
    render :json => {
        :status => "OK",
        :data => count
    }, :layout=> false

  end
  
  def eliminar_entrevistas
    ids = params[:ids]

    ids.each do | id |
      p = Entrevista.find Integer(id)
      p.vigente = "N"
      p.save
    end

    render :json => {
        :status => "OK",
        :data => nil
    }, :layout=> false
  end

  def consulta_entrevista
    @entrevista = Entrevista.find params[:id_entrevista]

    @estado = (EntrevistasEstados.find @entrevista.id_estado).descripcion

    @papa_escucha = ""
    if @entrevista.id_papa_escucha
      @papa_escucha = (PadresEscuchan.find @entrevista.id_papa_escucha)
      @papa_escucha = "#{@papa_escucha.apellidos}, #{@papa_escucha.nombres}"
    end

    @mama_escucha = ""
    if @entrevista.id_mama_escucha
      @mama_escucha = (PadresEscuchan.find @entrevista.id_mama_escucha)
      @mama_escucha = "#{@mama_escucha.apellidos}, #{@mama_escucha.nombres}"
    end

    render :action => "consulta_entrevista", :layout=> false
  end

  def alta_nueva_entrevista
    @papas_escuchan = PadresEscuchan.where("tipo = 'P' and vigente is null").select(:r_id, :nombres, :apellidos)
    @mamas_escuchan = PadresEscuchan.where("tipo = 'M' and vigente is null").select(:r_id, :nombres, :apellidos)
    @ubicaciones    = EntrevistasUbicaciones.select(:r_id, :descripcion)

    render :action => "alta_nueva_entrevista", :layout=> false
  end

  def alta_nuevo_hermano
    render :action => "alta_nuevo_hermano", :layout=> false
  end

  def cambiar_estado_entrevistas
    @ids_entrevistas = params[:ids_entrevistas]
    @estados = EntrevistasEstados.where("VIGENTE IS NULL").select(:r_id, :descripcion)
    render :action => "cambiar_estado_entrevistas", :layout=> false
  end

  def agendar_entrevistas
    @ids_entrevistas = params[:ids_entrevistas]
    render :action => "agendar_entrevistas", :layout=> false
  end

  def asignar_padres_entrevistas
    @ids_entrevistas = params[:ids_entrevistas]
    @papas_escuchan = PadresEscuchan.where("tipo = 'P' and vigente is null").select(:r_id, :nombres, :apellidos, :zona)
    @mamas_escuchan = PadresEscuchan.where("tipo = 'M' and vigente is null").select(:r_id, :nombres, :apellidos, :zona)
    render :action => "asignar_padres_entrevistas", :layout=> false
  end

  def do_cambiar_estados
    params[:ids_entrevistas].each do | id_entrevista |
      e = Entrevista.find Integer(id_entrevista)
      e.id_estado = Integer(params[:id_estado])
      e.save
    end
    render :json => {:status => "OK"}, :layout=> false
  end

  def do_agendar_entrevistas
    params[:ids_entrevistas].each do | id_entrevista |
      e = Entrevista.find Integer(id_entrevista)
      e.fecha_entrevista = params[:fecha_entrevista]
      e.cantidad_dias    = calcular_cantidad_dias e.fecha_llamada, e.fecha_entrevista
      e.save
    end
    render :json => {:status => "OK"}, :layout=> false
  end

  def do_asignar_padres_entrevistas
    params[:ids_entrevistas].each do | id_entrevista |
      e = Entrevista.find Integer(id_entrevista)
      e.id_papa_escucha = params[:id_papa_escucha].size > 0? Integer(params[:id_papa_escucha]) : nil
      e.id_mama_escucha = params[:id_mama_escucha].size > 0? Integer(params[:id_mama_escucha]) : nil
      e.save
    end
    render :json => {:status => "OK"}, :layout=> false
  end

  def actualizar_entrevista
    @papas_escuchan = PadresEscuchan.where("tipo = 'P' and vigente is null").select(:r_id, :nombres, :apellidos)
    @mamas_escuchan = PadresEscuchan.where("tipo = 'M' and vigente is null").select(:r_id, :nombres, :apellidos)
    @ubicaciones    = EntrevistasUbicaciones.select(:r_id, :descripcion)
    @entrevista = Entrevista.find params[:id_entrevista]
    render :action => "actualizar_entrevista", :layout=> false
  end


  def do_buscar_entrevistas_excel
    filter = ""
    filtrado = "Ninguno"
    filename = 'ASDRA_PAPE_ENTREVISTAS_COMPLETO.xlsx'
    if !params[:query].empty?
      filter = "AND #{params[:qtype]} like '%#{params[:query]}%'"
      filtrado = "#{params[:qtype]} = #{params[:query]}"
      filename = 'ASDRA_PAPE_ENTREVISTAS_FILTRADO.xlsx'
    end

    r = Entrevista.where("entrevistas.VIGENTE IS NULL #{filter}").order("entrevistas.r_ID DESC")
    .joins('INNER JOIN entrevistas_estados ee on ee.r_id = entrevistas.id_estado')
    .joins('LEFT JOIN padres_escuchan peP on peP.r_id = entrevistas.id_papa_escucha')
    .joins('LEFT JOIN padres_escuchan peM on peM.r_id = entrevistas.id_mama_escucha')
    .joins('LEFT JOIN entrevistas_ubicaciones eu on eu.r_id = entrevistas.id_ubicacion')
    .all.pluck(
        'entrevistas.r_id',
        :fecha_llamada,
        :fecha_entrevista,
        :lugar,
        :papa_telefonos,
        :papa_domicilio,
        :papa_nombre_apellido,
        :mama_telefonos,
        :mama_domicilio,
        :mama_nombre_apellido,
        :nombres,
        'ee.descripcion as descripcion_estado',
        "peP.apellidos || ' ' || peP.nombres as papa_escucha", # TODO: PAPE-28
        'peP.telefonos_sms as papa_telefonos_sms', # TODO: PAPE-84, PAPE-95
        'peP.zona as papa_zona',                   # TODO: PAPE-84, PAPE-95
        "peM.apellidos || ' ' || peM.nombres as mama_escucha", # TODO: PAPE-28
        'peM.telefonos_sms as mama_telefonos_sms', # TODO: PAPE-84, PAPE-95
        'peM.zona as mama_zona',                   # TODO: PAPE-84, PAPE-95
        'eu.descripcion as descripcion_ubicacion',
        :meses_nacimiento,
        :cobertura_medica,
        :fecha_nacimiento
    )

    p = Axlsx::Package.new
    wb = p.workbook


    wb.add_worksheet(:name => "Entrevistas") do |sheet|
      sheet.add_row ["Identificador", "Fecha Llamada", 'Fecha Entrevista', 'Lugar',
                     'Papa Telefonos', 'Papa Domicilio', 'Papa Nombre(s) y Apellido(s)',
                     'Mama Telefonos', 'Mama Domicilio', 'Mama Nombre(s) y Apellido(s)',
                     'Nombre(s) del Hijo/Hija', 'Estado',
                     'Papa Escucha', 'Papa Telefono(s) SMS', 'Papa Zona Geografica',
                     'Mama Escucha', 'Mama Telefono(s) SMS', 'Mama Zona Geografica',
                     'Ubicacion', 'Semanas de Nacimiento', 'Cobertura Medica', 'Fecha de Nacimiento del Hijo/Hija', 'Edad del Hijo/Hija']

      r.each do | row |
        if !(row[-1] && row[-1].empty?)
          row << baby_date(Date.parse(row[-1]))
        end

        sheet.add_row(row)
      end
      sheet.add_row [ '' ]
      sheet.add_row [ '' ]
      sheet.add_row ['Impreso el:', Time.now.to_s]
      sheet.add_row ['Filtro Impresion:', filtrado]
      sheet.add_row ['Cantidad de resultados:', r.size]
    end


    respond_to do |format|
      format.any {
        send_data(p.to_stream.read, :stream=>true, :disposition => "attachment", :filename => filename, :type => 'application/vnd.ms-excel; header=present')
      }
    end
  end

  def do_alta_nueva_entrevista

    ne = Entrevista.new

    ne.fecha_llamada    = params[:fecha_llamada]
    ne.lugar            = params[:lugar]
    ne.id_mama_escucha  = params[:mama_escucha]
    ne.id_papa_escucha  = params[:papa_escucha]
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
    ne.sexo             = params[:sexo].size>0? params[:sexo][0].upcase : nil
    ne.fecha_nacimiento = params[:fecha_nacimiento]
    ne.institucion_nacimiento = params[:institucion_nacimiento]
    ne.observacion_institucion= params[:observacion_institucion]
    ne.meses_nacimiento = params[:meses_nacimiento]
    ne.parto_normal     = params[:parto_normal]? 'S' : 'N'
    ne.sabia_sdown      = params[:sabia_sdown]? 'S' : 'N'
    ne.recepcion_flia   = params[:recepcion_flia]
    ne.patologia_agregada = params[:patologia_agregada]
    ne.observaciones    = params[:observaciones]
    ne.id_ubicacion     = params[:id_ubicacion].size>0? params[:id_ubicacion] : nil
    ne.id_estado        = 1 # TODO: Estado Pendiente - Refactorizar!
    ne.nombres          = params[:nombres]
    ne.hermanos_json    = params[:hermanos_json]
    ne.cobertura_medica = params[:cobertura_medica]
    ne.cantidad_dias    = 0
    ne.save

    render :json => {:status => "OK"}, :layout=> false
  end


  def do_actualizar_entrevista

    ne = Entrevista.find(params[:identificador])

    ne.fecha_llamada    = params[:fecha_llamada]
    ne.lugar            = params[:lugar]
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
    ne.sexo             = params[:sexo].size>0? params[:sexo][0].upcase : nil
    ne.fecha_nacimiento = params[:fecha_nacimiento]
    ne.institucion_nacimiento = params[:institucion_nacimiento]
    ne.observacion_institucion= params[:observacion_institucion]
    ne.meses_nacimiento = params[:meses_nacimiento]
    ne.parto_normal     = params[:parto_normal]? 'S' : 'N'
    ne.sabia_sdown      = params[:sabia_sdown]? 'S' : 'N'
    ne.recepcion_flia   = params[:recepcion_flia]
    ne.patologia_agregada = params[:patologia_agregada]
    ne.observaciones    = params[:observaciones]
    ne.id_ubicacion     = params[:id_ubicacion].size>0? params[:id_ubicacion] : nil
    ne.nombres          = params[:nombres]
    ne.cantidad_dias    = calcular_cantidad_dias params[:fecha_llamada], params[:fecha_entrevista]
    ne.hermanos_json    = params[:hermanos_json]
    ne.cobertura_medica = params[:cobertura_medica]
    ne.save

    render :json => {:status => "OK"}, :layout=> false
  end

  def buscar_entrevistas
    render :action => "buscar_entrevistas", :layout=> false
  end

  def do_buscar_entrevistas
    filter = ""
    if !params[:query].empty?
      filter = "AND #{params[:qtype]} like '%#{params[:query]}%'"
    end

    r = Entrevista.where("entrevistas.VIGENTE IS NULL #{filter}").order("entrevistas.fecha_llamada DESC")
        .joins('INNER JOIN entrevistas_estados ee on ee.r_id = entrevistas.id_estado')
        .joins('LEFT JOIN padres_escuchan peP on peP.r_id = entrevistas.id_papa_escucha')
        .joins('LEFT JOIN padres_escuchan peM on peM.r_id = entrevistas.id_mama_escucha')
        .joins('LEFT JOIN entrevistas_ubicaciones eu on eu.r_id = entrevistas.id_ubicacion')
        .all.pluck(
        'cantidad_dias',
        'entrevistas.r_id',
        :fecha_llamada,
        :fecha_entrevista,
        'ee.descripcion as descripcion_estado',
        "peP.apellidos || ' ' || peP.nombres as papa_escucha", # TODO: PAPE-28
        "peM.apellidos || ' ' || peM.nombres as mama_escucha", # TODO: PAPE-28
        'nombres',
        'eu.descripcion as descripcion_ubicacion',
        'fecha_nacimiento',
        'ee.color as color_estado'
    )

    return_data = {}

    return_data[:page] = 1

    return_data[:total] = r.size

    r2 = []

    r.each do | e |
       # e[-1] es fecha_nacimiento
       if !(e[-2] && e[-2].empty?)
        e[-2] = baby_date(Date.parse(e[-2]))
       end

      r2  << {:cell=>e}
    end

    return_data[:rows] = r2

    render :json => return_data, :layout=> false

  end

  private

  def calcular_cantidad_dias fecha_llamada, fecha_entrevista

    if fecha_llamada && !fecha_llamada.empty? && fecha_entrevista && !fecha_entrevista.empty?
      (Date.parse(fecha_llamada ) - Date.parse(fecha_entrevista)).to_i
    else
      ''
    end
  end

  def baby_date(dob)
    # TODO: PAPE-30
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end
  
  def enviar_correo_notificar_entrevistas_sin_asignar nombre, correo
      logger.debug "enviando correo a: #{nombre} - #{correo}"
      
      message = "From: Notificador ASDRA PAPE <pape-noreply@pape-noreply>\nTo: Sr/a. Papa/Mama #{nombre} <#{correo}>\nSubject: Hay entrevistas sin asignar!\n/\n"
      Net::SMTP.start('localhost') do |smtp|
        smtp.send_message message, 'pape-noreply@pape-noreply', "#{correo}"
      end
  end
      
end
