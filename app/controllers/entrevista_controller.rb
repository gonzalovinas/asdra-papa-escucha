class EntrevistaController < ApplicationController

  def index
  end


  def alta_nueva_entrevista
    render :action => "alta_nueva_entrevista", :layout=> false
  end

  def do_alta_nueva_entrevista

    ne = Entrevista.new
    ne.fecha = params[:fecha_llamada]
    ne.lugar = params[:lugar]
    ne.save

    render :json => {:status=>"OK"}
  end

end
