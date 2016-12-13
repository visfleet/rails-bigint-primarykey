require 'rails/railtie'

class BigintPk::Railtie < Rails::Railtie
  initializer 'bigint_pk.install' do
    ActiveSupport.on_load(:active_record) do
      BigintPk.enable!
    end
  end
end
