class EntrevistaController < ApplicationController

  def index
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
    render :action => "consulta_entrevista", :layout=> false
  end

  def alta_nueva_entrevista
    @papas_escuchan = PadresEscuchan.where("tipo = 'P' and vigente is null").select(:r_id, :nombres, :apellidos)
    @mamas_escuchan = PadresEscuchan.where("tipo = 'M' and vigente is null").select(:r_id, :nombres, :apellidos)
    @ubicaciones    = EntrevistasUbicaciones.select(:r_id, :descripcion)

    render :action => "alta_nueva_entrevista", :layout=> false
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
        :fecha_nacimiento

    )

    p = Axlsx::Package.new
    wb = p.workbook


    wb.add_worksheet(:name => "Entrevistas") do |sheet|
      sheet.add_row ["Identificador", "Fecha Entrevista", 'Fecha Llamada', 'Lugar',
                     'Papa Telefonos', 'Papa Domicilio', 'Papa Nombre(s) y Apellido(s)',
                     'Mama Telefonos', 'Mama Domicilio', 'Mama Nombre(s) y Apellido(s)',
                     'Nombre(s) del Hijo/Hija', 'Estado', 'Papa Escucha', 'Mama Escucha',
                     'Ubicacion', 'Fecha de Nacimiento del Hijo/Hija', 'Edad del Hijo/Hija']

      r.each do | row |
        if !(row[-1].empty? && row[-1])
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
    ne.fecha_entrevista = params[:fecha_llamada]
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

    r = Entrevista.where("entrevistas.VIGENTE IS NULL #{filter}").order("entrevistas.r_ID DESC")
        .joins('INNER JOIN entrevistas_estados ee on ee.r_id = entrevistas.id_estado')
        .joins('LEFT JOIN padres_escuchan peP on peP.r_id = entrevistas.id_papa_escucha')
        .joins('LEFT JOIN padres_escuchan peM on peM.r_id = entrevistas.id_mama_escucha')
        .joins('LEFT JOIN entrevistas_ubicaciones eu on eu.r_id = entrevistas.id_ubicacion')
        .all.pluck(
        'entrevistas.r_id',
        :fecha_entrevista,
        :fecha_llamada,
        'ee.descripcion as descripcion_estado',
        "peP.apellidos || ' ' || peP.nombres as papa_escucha", # TODO: PAPE-28
        "peM.apellidos || ' ' || peM.nombres as mama_escucha", # TODO: PAPE-28
        'nombres',
        'eu.descripcion as descripcion_ubicacion',
        'fecha_nacimiento'
    )

    return_data = {}

    return_data[:page] = 1

    return_data[:total] = r.size

    r2 = []

    r.each do | e |
      # e[-1] es fecha_nacimiento
      if !(e[-1].empty? && e[-1])
        e[-1] = baby_date(Date.parse(e[-1]))
      end

      r2  << {:cell=>e}
    end

    return_data[:rows] = r2

    render :json => return_data, :layout=> false

  end

  private

  def baby_date(dob)
    # TODO: PAPE-30
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end
end
