
module P0fParser
  class Parser
    def add_data(new_data)
      raise ArgumentError unless new_data.kind_of?(String)

      # We create a new scanner with any data we haven't processed yet to
      # prevent ballooning our memory with all the prior data we no longer
      # need.
      @scanner = StringScanner.new(@scanner.rest + new_data)
    end

    def initialize
      @scanner = StringScanner.new("")
    end

    # We could potentially loose a single entry if this gets run before an
    # entire entry is loaded into the scanner. When this happens the first will
    # match the second will fail, and the next time it gets run it will skip
    # over the remaining bits of this entry.
    def next_entry
      # Scan till we get to the beginning of an entry
      return unless @scanner.scan_until(/\.-\[/)

      # Grab the contents of the entry and return nothing if we can't find one.
      return unless entry = @scanner.scan_until(/^`----$/)

      # Process and return the entry we've gotten up too this point
      process_entry(entry)
    end

    private

    def process_entry(entry)
      lines = entry.lines

      output = process_header(lines.shift)
      output["data"] = extract_kvs(lines)

      output
    end

    def process_header(hline)
      prehash = P0fParser::HEADER_FORMAT.names.zip(P0fParser::HEADER_FORMAT.match(hline).captures)
      prehash.keep_if { |i| ["source_ip", "source_port", "dest_ip", "dest_port", "rule"].include?(i[0]) }

      Hash[prehash]
    end

    def extract_kvs(lines)
      data = lines.map do |l|
        # Skip if this line if it's empty
        next unless P0fParser::DATALINE_FORMAT =~ l
        P0fParser::DATALINE_FORMAT.match(l).captures
      end

      data.reject! { |d| d == nil }
      Hash[data]
    end
  end
end
