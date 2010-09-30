begin
  require 'rubygems'
  gem 'jeweler'
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "ruby_unify"
    #s.executables = ""
    s.summary = "Simple Pattern Matching and Unification Library"
    s.email = "ks.ruby@kurtstephens.com"
    s.homepage = "http://github.com/kstephens/ruby_unify"
    s.description = s.summary
    s.authors = ["Kurt Stephens"]
    s.files = FileList["[A-Z]*", "{bin,generators,lib,test}/**/*" ]
    #s.add_dependency 'schacon-git'
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler -s http://gems.github.com"
end

require 'rake'
require 'spec/rake/spectask'

desc "Run all tests with RCov"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_files = FileList['test/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = [
                 # '--exclude', 'test', 
                 '--exclude', '/var/lib',
                ]
end
