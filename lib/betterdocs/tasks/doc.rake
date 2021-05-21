namespace :doc do
  desc 'Create the API documentation'
  task api: :'doc:api:sandbox' do
    Betterdocs::Global.config do |config|
      Betterdocs::Generator::Markdown.new(only: ENV['ONLY']).generate
      cd config.output_directory do
        File.open('.gitignore', 'w') { |ignore| ignore.puts config.ignore }
      end
    end
  end

  task :set_betterdocs_env do
    ENV['BETTERDOCS'] = '1'
  end

  namespace :api do
    desc 'Let database transactions run in a sandboxed environment'
    task sandbox: %i[doc:set_betterdocs_env environment] do
      ActiveRecord::Base.connection.begin_db_transaction
      at_exit do
        ActiveRecord::Base.connection.rollback_db_transaction
      end
    end

    desc 'Create the API swagger documentation'
    task swagger: :'doc:api:sandbox' do
      Betterdocs::Global.config do |config|
        Betterdocs::Generator::Swagger.new(only: ENV['ONLY']).generate
        cd config.swagger_output_directory do
          File.open('.gitignore', 'w') { |ignore| ignore.puts config.ignore }
        end
      end
    end

    desc 'Push the newly created API documentation to the remote git repo'
    task push: :api do
      Betterdocs::Global.config do |config|
        config.publish_git or raise 'Configure a git repo as publish_git to publish to'
        cd config.output_directory do
          File.directory?('.git') or sh 'git init'
          sh 'git remote rm publish_git || true'
          sh "git remote add publish_git #{config.publish_git}"
          sh 'git add -A'
          sh 'git commit -m "Add some more changes to API documentation" || true'
          sh 'git push -f publish_git master'
        end
      end
    end

    desc 'Publish the newly created API documentation'
    task publish: [:push]

    desc 'Publish and view the newly created API documentation'
    task view: :publish do
      Betterdocs::Global.config do |config|
        url = config.publish_git
        url.sub!(/.*?([^@]*):/, 'http://\1/') if url !~ /\Ahttps?:/
        sh "open #{url.inspect}"
      end
    end
  end
end
