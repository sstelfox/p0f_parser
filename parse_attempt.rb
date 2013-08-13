
require 'json'
require 'open3'
require 'strscan'

HEADER = %r{
  (?<octet> (25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){0}
  (?<ipv4> (\g<octet>\.){3}\g<octet>){0}
  (?<ipv6> ((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]? \d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?){0}
  (?<port> (6[0-5][0-5][0-3][0-5]|6[0-4][0-9]{3}|[1-5][0-9]{4}|[1-9][0-9]{1,3}|[0-9])){0}
  (?<rule>.+){0}

  (?<source_ip> \g<ipv4>|\g<ipv6>){0}
  (?<source_port> \g<port>){0}

  (?<dest_ip> \g<ipv4>|\g<ipv6>){0}
  (?<dest_port> \g<port>){0}

  \g<source_ip>\/\g<source_port>[ ]->[ ]\g<dest_ip>\/\g<dest_port>[ ]\(\g<rule>\)
}x

DATALINE = %r{
  (?<key> \S+){0}
  (?<value> \S+){0}

  \g<key>\s+=\s+\g<value>
}x

class Parser
  def self.next_entry(input)
    # Scan till we get to the beginning of an entry
    return unless input.scan_until(/\.-\[/)

    # Return the contents of the entry
    input.scan_until(/^`----$/)
  end

  def self.process_entry(entry)
    lines = entry.lines

    data = process_header(lines.shift)
    data["data"] = extract_kvs(lines)

    data
  end

  def self.process_header(hline)
    prehash = HEADER.names.zip(HEADER.match(hline).captures)
    prehash.keep_if { |i| ["source_ip", "source_port", "dest_ip", "dest_port", "rule"].include?(i[0]) }
    Hash[prehash]
  end

  def self.extract_kvs(lines)
    data = lines.map do |l|
      next unless DATALINE =~ l
      DATALINE.match(l).captures
    end

    data.reject! { |d| d == nil }
    Hash[data]
  end
end

unless Process.uid == 0
  puts "You need to run this program as root..."
  exit!(1)
end

Open3.popen3("p0f -i wlp3s0") do |stdin, stdout, stderr, wait_thr|
  pid = wait_thr.pid
  stdin.close # We don't need stdin for anything

  # Begin our loop
  new_data = stdout.read_nonblock(1024) rescue ""
  ss = StringScanner.new(new_data)

  while !stdout.closed?
    new_data = stdout.read_nonblock(1024) rescue ""
    ss = StringScanner.new(ss.rest + new_data)

    while e = Parser.next_entry(ss)
      puts JSON.generate(Parser.process_entry(e))
    end
  end

  stderr.close unless stderr.closed?
  stdout.close unless stdout.closed?
  
  # Prevent zombie processes even if we don't use this
  exit_status = wait_thr.value
end

