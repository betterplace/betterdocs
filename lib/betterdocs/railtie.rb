module Betterdocs
  class Railtie < Rails::Railtie
    initializer 'betterdocs.configure_rails_initialization' do
      Betterdocs::Global.configure
    end
  end
end
