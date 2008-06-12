require 'rubygems'
require 'echoe'

task :default => :test

Echoe.new("backcall") do |p|
  p.author = "Ari Lerner"
  p.email = "ari.lerner@citrusbyte.com"
  p.summary = "Add basic memory-efficient before and after callbacks, easily"
  p.url = "http://blog.citrusbyte.com"
  p.dependencies = %w(facets)  
  p.install_message = "Backcall\n----------------------\nEasy, memory efficient callbacks\n\nUsage:\nrequire 'backcall'\n\nclass TestClass\n\tinclude Callbacks\n\n\tbefore :world, :hello\n\n\tmethods...\nend\n----------------------\n\nFor more information, check http://blog.citrusbyte.com\n*** Ari Lerner @ <ari.lerner@citrusbyte.com> ***"
  p.include_rakefile = true
end