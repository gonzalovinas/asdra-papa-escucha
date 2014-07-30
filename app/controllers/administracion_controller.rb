
class AdministracionController < ApplicationController

  def do_mantenimiento
    plan_mantenimiento = params[:id_mantenimiento]

    case plan_mantenimiento # TODO: Refactor!
      when "MANT00"
        MensajesNovedades.delete_all
      when "MANT01"
        MensajesNovedades.where("r_id not in (select r_id from mensajes_novedades order by r_id desc limit 3)").delete_all
      else
        raise Exception
    end

    render :json => {
        :status => "OK",
        :data => nil
    }, :layout=> false

  end

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

  def administrar_estados_entrevistas
    render :action => "administrar_estados_entrevistas", :layout=> false
  end

  def buscar_padres
    render :action => "buscar_padres", :layout=> false
  end

  def eliminar_estados_entrevistas
    ids = params[:ids]

    ids.each do | id |
      p = EntrevistasEstados.find Integer(id)
      
      next if p.id == 1 # TODO: FIXME: Estado Id=1 Creada/Pendiente no se puede borrar...
      
      p.vigente = "N"
      p.save
    end

    render :json => {
        :status => "OK",
        :data => nil
    }, :layout=> false
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

  def do_buscar_padres_excel
    filter = ""
    filtrado = "Ninguno"
    filename = 'ASDRA_PAPE_ENTREVISTAS_COMPLETO.xlsx'

    if !params[:query].empty?
      filter = "AND #{params[:qtype]} like '%#{params[:query]}%'"
      filtrado = "#{params[:qtype]} = #{params[:query]}"
      filename = 'ASDRA_PAPE_ENTREVISTAS_FILTRADO.xlsx'
    end
    r = PadresEscuchan.where("vigente IS NULL #{filter}").order("r_ID DESC").all.pluck(
        :r_id,
        :apellidos,
        :nombres,
        :correo,
        :telefonos,
        :tipo
    )

    p = Axlsx::Package.new
    p.use_autowidth = true
    wb = p.workbook

    wb.add_worksheet(:name => "Padres que Escuchan") do |sheet|
      sheet.add_row ["Identificador", "Apellido(s)", 'Nombre(s)', 'Correo', 'Telefono(s)', 'Papa o Mama']
      r.each do | row |
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

  def do_buscar_estados_entrevistas
    r = EntrevistasEstados.where("vigente IS NULL").order("r_ID DESC").all.pluck(
        :r_id,
        :descripcion,
        :descripcion_uso,
        :color
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
        :telefonos,
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

  def alta_nuevo_estado_entrevista
    render :action => "alta_nuevo_estado_entrevista", :layout=> false
  end

  def alta_nuevo_padre
    render :action => "alta_nuevo_padre", :layout=> false
  end

  def do_alta_nuevo_estado_entrevista
    ee = EntrevistasEstados.new

    ee.descripcion     = params[:nombre]
    ee.descripcion_uso = params[:descripcion_uso]
    ee.color           = params[:color]
    ee.save

    render :json => {
        :status => "OK",
        :data => {
            :id_padre_escucha => ee.r_id
        }
    }, :layout=> false
  end

  def do_alta_nuevo_padre
    pe = PadresEscuchan.new

    pe.apellidos= params[:apellidos]
    pe.nombres  = params[:nombres]
    pe.correo   = params[:correo]
    pe.telefonos= params[:telefonos]
    pe.tipo     = params[:tipo]

    pe.save

    mn = MensajesNovedades.new
    mn.mensaje = "Bienvenido #{pe.nombres} #{pe.apellidos}!"
    mn.fecha = Time.now.strftime("%d-%m-%Y %H:%M")
    mn.save

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
