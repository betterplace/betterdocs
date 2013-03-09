namespace :doc do
  desc "Create the API documentation"
  task :api => :environment do
    Betterdocs::Global.config do |config|
      Betterdocs::Generator::Markdown.new.generate
      cd config.output_directory do
        File.open('.gitignore', 'w') { |ignore| ignore.puts config.ignore }
      end
    end
  end

  namespace :api do
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
          sh 'git push publish_git -f'
        end
      end
    end

    desc "Publish the newly created API documentation"
    task :publish => [ :push ]
  end
end
