ENV['gem_push'] = 'false'

require "bundler/gem_tasks"

desc 'Release and push the gem to geminabox'
task 'geminabox' do
   Rake::Task['build'].invoke
   Rake::Task['release'].invoke
   system('gem inabox')
end
