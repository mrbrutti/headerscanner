require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = "HeaderScanner"
  s.version = "0.0.5"
  s.author = "Matias P. Brutti"
  s.email = "matiasbrutti@gmail.com"
  s.homepage = "http://www.freedomcoder.com.ar"
  s.platform = Gem::Platform::RUBY
  s.summary = "Header Scanner with some extras"
  s.files = Dir.glob("{lib}/**/*") + Dir.glob("{test}/**/*")
  s.require_path = "lib"
  s.add_dependency("httpclient", ">= 2.1.2")
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end 

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

