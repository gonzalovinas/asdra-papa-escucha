class WelcomeController < ApplicationController

  def index
  end

  def resumen
    @mensajes_novedades = MensajesNovedades.last(5)
    render :action => "resumen", :layout=> false
  end

  def alta_nueva_entrevista
    render :action => "alta_nueva_entrevista", :layout=> false
  end

  def do_alta_nueva_entrevista
    render :json => {:status=>"Mensaje Recibido"}
  end

end
