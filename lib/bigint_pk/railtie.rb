require 'rails/railtie'

class BigintPk::Railtie < Rails::Railtie
  initializer 'bigint_pk.install' do
    BigintPk.enable! if defined?(ActiveRecord)
  end
end
