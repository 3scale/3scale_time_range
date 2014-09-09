ENV['gem_push'] = 'false'
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

desc 'Release and push the gem to geminabox'
task 'geminabox' do
  Rake::Task['build'].invoke
  Rake::Task['release'].invoke
  system('gem inabox')
end
