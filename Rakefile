require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Tag & release the gem'
task :release => :spec do
  $: << 'lib'
  require 'ciql/version'

  name = 'ciql'
  version = "v#{Ciql::VERSION}"
  
  unless %x(git tag -l).split("\n").include?(version)
    system %(git tag -a #{version} -m #{version})
  end

  system %(git push && git push --tags; gem build #{name}.gemspec && gem push #{name}-*.gem && mv #{name}-*.gem pkg)
end
