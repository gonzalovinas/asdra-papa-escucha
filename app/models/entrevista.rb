class Entrevista < ActiveRecord::Base
  self.table_name = 'entrevistas'
end

class EntrevistasEstados < ActiveRecord::Base
  self.table_name = 'entrevistas_estados'
end

class EntrevistasUbicaciones< ActiveRecord::Base
  self.table_name = 'entrevistas_ubicaciones'

end

