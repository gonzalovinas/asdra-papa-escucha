class WelcomeController < ApplicationController

  def index
  end

  def resumen
    @mensajes_novedades = MensajesNovedades.last(5).reverse
    render :action => "resumen", :layout=> false
  end

end
