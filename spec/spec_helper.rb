$:.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

%w(test/spec backcall).each do |library|
  begin
    require library
  rescue
    STDERR.puts "== Cannot run test without #{library}"
  end
end

include Backcall