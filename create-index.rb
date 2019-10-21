require 'erb'
require 'json'
require 'ostruct'
require 'date'

Encoding.default_external = 'utf-8'

def render(template_filename, vars)
  bind = OpenStruct.new(vars).instance_eval { binding }
  template = File.read(template_filename)
  ERB.new(template).result(bind)
end

codes_filename = ARGV[0]
if codes_filename.nil?
  puts 'Expected codes path.'
  exit 1
end

template_filename = ARGV[1]
if template_filename.nil?
  puts 'Expected template path.'
  exit 1
end

output_filename = ARGV[2]
if output_filename.nil?
  puts 'Expected output path.'
  exit 1
end

now = DateTime.now
codes = JSON.parse(File.read(codes_filename), object_class: OpenStruct)
codes.each do |code|
  code.start = DateTime.strptime(code.start, '%Y-%m-%d')
  if !code.end.nil?
    code.end = DateTime.strptime(code.end, '%Y-%m-%d')
  end
  code.is_expired = !code.end.nil? && now >= code.end
end

compare = lambda do |p, q|
  if p.is_expired
    if q.is_expired
      ends = q.end <=> p.end
      return ends if ends != 0
    else
      return 1
    end
  elsif q.is_expired
    return -1
  end

  return q.start <=> p.start
end

codes.sort! do |p, q|
  compare.call(p, q)
end

content = render(template_filename, codes: codes, render: method(:render))
File.write(output_filename, content)