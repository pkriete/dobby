# Used to extend ARGV
#
module DobbyArgv

  def parse(options)
    result = {}

    options.each_pair do |k, v|
      value = find_value(k, v[:alias])
      result[k] = value || v[:default]
    end

    result
  end

  def find_value(key, alternate)
    position = index do |v|
      v == key or v.start_with?(alternate + '=')
    end

    if position == nil
      return nil
    end

    if fetch(position).start_with?(alternate + '=')
      fetch(position)[alternate + '='] = ''
    else
      fetch(position + 1)
    end
  end

end