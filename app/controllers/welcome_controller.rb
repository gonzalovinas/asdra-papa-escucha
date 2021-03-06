require "rss"

class WelcomeController < ApplicationController

  def index
  end

  def login
      render :action => "login", :layout => false
  end
  
  def do_login
    session[:iniciado]=true
    if params[:password] == "asdrapape2014"
        session[:logged] = "SI"

        render :json => {
            :status => "OK",
            :data => nil
        }, :layout=> false

    else
      render :json => {
          :status => "ERROR",
          :data => nil
      }, :layout=> false

    end
  end
  
    
  def resumen
    @mensajes_novedades = MensajesNovedades.last(5).reverse
    @cantidad_entrevistas = Entrevista.count

    @cantidad_padres_escuchan = PadresEscuchan.where(:tipo => "P").count
    @cantidad_madres_escuchan = PadresEscuchan.where(:tipo => "M").count

    render :action => "resumen", :layout => false
  end

  def acerca
    render :action => "acerca", :layout => false
  end

  def acerca_sistema
    render :action => "acerca_sistema", :layout => false
  end

  def acerca_marcas
    render :action => "acerca_marcas", :layout => false
  end


  def acerca_soporte
    render :action => "acerca_soporte", :layout => false
  end


  def mensajes_novedades_rss

    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author = "ASDRA Papa Escucha"
      maker.channel.updated = Time.now.to_s
      maker.channel.about = "http://www.asdra.org.ar/"
      maker.channel.title = "Ultimas novedades Papa Escucha"

      novedades = MensajesNovedades.last(5).reverse

      novedades.each do | novedad |

        maker.items.new_item do |item|
          item.link = "http://www.asdra.org.ar"
          item.title = novedad.mensaje
          item.updated = novedad.fecha
        end

      end

    end

    render :text => rss, :layout => false

  end

end
