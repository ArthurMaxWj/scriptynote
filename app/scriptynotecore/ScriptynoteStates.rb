class ScriptynoteStates
  MARKERS = %i[bold italic underline header]
  MARKERS_COMPLEX = %i[header]

  def initialize
    @states = MARKERS.index_with(false)
    @specials = MARKERS_COMPLEX.index_with(false)
    @is_endl_used = false
    @endl_marker = nil

    @marker_data = {}
  end

  def on?(name)
    @states[name.to_sym]
  end

  def set(name, val, force_complex = false)
    raise "Dont use set method on complex markers" if MARKERS_COMPLEX.include?(name) && !force_complex

    @states[name.to_sym] = val
  end

  def on(name) = set(name, true)
  def off(name) = set(name, false)

  def switch(name)
    set(name, !on?(name))
  end

  def switch_get(name)
    switch(name)

    !on?(name)
  end

  def endl? = @is_endl_used
  def endl_marker = @endl_marker

  def marker_header(action)
    case action
    when :on
      @is_endl_used = true
      @endl_marker = :header
      write(:header, :level, 1)
      start_special(:header)
    when :off
      @is_endl_used = false
      @endl_marker = nil
      stop_special(:header)
    when :upgrade
      lev = read(:header, :level)
      write(:header, :level, lev + 1) unless lev == 6
    else
      raise "unknown : #{action}"
    end
  end

  def start_special(name)
    @specials[name] = true
  end

  def stop_special(name)
    @specials[name] = false
  end

  def special?
    @specials.values.any?
  end

  def inside_special?(name)
    @specials[name]
  end

  def read(marker_name, key)
    data = @marker_data.dig(marker_name, key)
    raise "unknown marker/key: #{marker_name}/#{key}" if data.nil?

    data
  end

  def write(marker_name, key, val)
    @marker_data[:header] ||= {}
    @marker_data[marker_name][key] = val
  end
end
