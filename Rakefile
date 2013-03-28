require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Tag & release the gem'
task :release => :spec do
  $: << 'lib'
  require 'ciql/version'

  project_name = 'ciql'
  version_string = "v#{Ciql::VERSION}"
  
  unless %x(git tag -l).include?(version_string)
    system %(git tag -a #{version_string} -m #{version_string})
  end

  system %(git push && git push --tags; gem build #{project_name}.gemspec && gem push #{project_name}-*.gem && mv #{project_name}-*.gem pkg)
end
