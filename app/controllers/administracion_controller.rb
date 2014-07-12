
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

  def do_buscar_padres_excel
    filter = ""
    filtrado = "Ninguno"
    if !params[:query].empty?
      filter = "AND #{params[:qtype]} like '%#{params[:query]}%'"
      filtrado = "#{params[:qtype]} = #{params[:query]}"
    end
    r = PadresEscuchan.where("vigente IS NULL #{filter}").order("r_ID DESC").all.pluck(
        :r_id,
        :apellidos,
        :nombres,
        :correo,
        :tipo
    )

    p = Axlsx::Package.new
    wb = p.workbook


    wb.add_worksheet(:name => "Padres que Escuchan") do |sheet|
      sheet.add_row ["Identificador", "Apellido(s)", 'Nombre(s)', 'Correo', 'Papa o Mama']
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
        send_data(p.to_stream.read, :stream=>true, :disposition => "attachment", :filename => 'rpt.xlsx', :type => 'application/vnd.ms-excel; header=present')
      }
    end
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
