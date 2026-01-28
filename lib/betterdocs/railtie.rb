module Betterdocs
  class Railtie < Rails::Railtie
    initializer 'betterdocs.configure_rails_initialization' do
      Betterdocs::Global.configure
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |f| load f }
    end
  end
end
