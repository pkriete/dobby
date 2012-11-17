# Used to extend ARGV
#
module DobbyArgv

  # Turn options into a hash
  #
  def parse(options)
    result = {}

    options.each_pair do |k, v|
      value = find_value(k, v[:alias])
      result[k] = value || v[:default]
    end

    result
  end

  # Find value of a given flag.
  #
  def find_value(key, alternate)
    alternate << '='

    position = index do |v|
      v == key || v.start_with?(alternate)
    end

    return nil unless position

    if fetch(position).start_with?(alternate)
      fetch(position)[alternate] = ''
    else
      position += 1
    end

    fetch(position)
  end

end