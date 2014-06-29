require "rss"

class WelcomeController < ApplicationController

  def index
  end

  def resumen
    @mensajes_novedades = MensajesNovedades.last(5).reverse

    render :action => "resumen", :layout => false
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
