namespace :doc do
  desc "Create the API documentation"
  task :api => :'doc:api:sandbox' do
    Betterdocs::Global.config do |config|
      Betterdocs::Generator::Markdown.new.generate
      cd config.output_directory do
        File.open('.gitignore', 'w') { |ignore| ignore.puts config.ignore }
      end
    end
  end

  namespace :api do
    desc 'Let database transactions run in a sandboxed environment'
    task :sandbox => :environment do
      ActiveRecord::Base.connection.increment_open_transactions
      ActiveRecord::Base.connection.begin_db_transaction
      at_exit do
         ActiveRecord::Base.connection.rollback_db_transaction
         ActiveRecord::Base.connection.decrement_open_transactions
      end
    end

    desc "Push the newly created API documentation to the remote git repo"
    task :push => :api do
      Betterdocs::Global.config do |config|
        config.publish_git or fail "Configure a git repo as publish_git to publish to"
        cd config.output_directory do
          File.directory?('.git') or sh "git init"
          sh "git remote rm publish_git || true"
          sh "git remote add publish_git #{config.publish_git}"
          sh "git add -A"
          sh 'git commit -m "Add some more changes to API documentation" || true'
          sh 'git push -f publish_git master'
        end
      end
    end

    desc "Publish the newly created API documentation"
    task :publish => [ :push ]

    desc "Publish and view the newly created API documentation"
    task :view => :publish do
      Betterdocs::Global.config do |config|
        url = config.publish_git
        if url !~ /\Ahttps?:/
          url.sub!(/.*?([^@]*):/, 'http://\1/')
        end
        sh "open #{url.inspect}"
      end
    end
  end
end
