require 'rails/railtie'

class BigintPrimarykey::Railtie < Rails::Railtie
  initializer 'bigint_primarykey.install' do
    ActiveSupport.on_load(:active_record) do
      config = configurations[Rails.env]
      BigintPrimarykey.enable!(config['adapter'])
    end
  end
end
