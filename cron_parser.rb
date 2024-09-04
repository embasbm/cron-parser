class CronParser
  def initialize(cron_string)
    @cron_string = cron_string
  end

  def parse
    fields = set_args
    {
      "minute" => expand(fields[0], 0, 59, []),
      "hour" => expand(fields[1], 0, 23, []),
      "day of month" => expand(fields[2], 1, 31, []),
      "month" => expand(fields[3], 1, 12, []),
      "day of week" => expand(fields[4], 0, 6, []),
      "command" => fields[5]
    }
  end

  def expand(field, min, max, result)
    raise_non_valid_cron!(field, min, max)

    return result if field.empty?
    return (min..max).to_a if field == "*"

    if field.include?("/")
      interval = field.split("/")
      start = interval[0] == "*" ? min : interval[0].to_i
      step = interval[1].to_i
      result = (start..max).step(step).to_a
    elsif field.include?(",")
      result = field.split(",").map(&:to_i).sort + expand(field.split(",").last, min, max, result)
    elsif field.include?("-")
      range = field.split("-").map(&:to_i)
      result = (range[0]..range[1]).to_a
    else
      result = [field.to_i]
    end

    result.uniq
  end

  def display
    puts ARGV[0]
    parse.each do |key, value|
      puts "#{key.ljust(14)} #{value.is_a?(Array) ? value.join(" ") : value}"
    end
  end

  private

  def raise_non_valid_cron!(field, min, max)
    unless field.match?(/\A[\d,\/\-\*]+\z/)
      raise ArgumentError.new("Invalid field format: '#{field}'. Only numbers, commas, slashes, and hyphens are allowed.")
    end

    if field.include?("/") 
      field_parts = field.split("/")
      if field_parts.uniq.size != 2 || field_parts.any? { |f| f.empty? || (f.is_a?(Integer) && f.to_i < min) || (f.is_a?(Integer) && f.to_i > max) }
        raise ArgumentError.new(("Non standard! May not work with every cron."))
      end
    end
  end

  def set_args
    fields = @cron_string.split(" ")

    raise ArgumentError.new("Invalid cron length.") if fields.size != 6

    fields
  end
end

# If the script is run directly from terminal
if __FILE__ == $PROGRAM_NAME
  begin
    raise ArgumentError.new("Usage: ruby #{__FILE__} '<cron_string>'") if ARGV.length != 1

    cron_parser = CronParser.new(ARGV[0])
    cron_parser.display
  rescue ArgumentError => e  
    puts "Error ocurred: #{e.message}"
    exit
  end
end
