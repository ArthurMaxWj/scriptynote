class ScriptynoteStates
  MARKERS = %i[bold italic underline header]
  MARKERS_COMPLEX = %i[header]
  MARKERS_SIMPLE = %i[bold italic underline]


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

  def endl? = @is_endl_used
  def endl_marker = @endl_marker

  def special?
    @specials.values.any?
  end

  def inside_special?(name)
    @specials[name]
  end

  def read(marker_name, key)
    data = @marker_data.dig(marker_name, key)
    raise "Unknown marker/key: #{marker_name}/#{key}" if data.nil?

    data
  end

  def write(marker_name, key, val)
    @marker_data[marker_name] ||= {}
    @marker_data[marker_name][key] = val
  end

  def marker(name, action)
    raise "Unknown marker: #{name}" unless MARKERS.include?(name)

    if MARKERS_COMPLEX.include?(name)
      if name == :header
        marker_header(action)
      else
        raise "Unimmplemented complex marker: #{name}"
      end
    elsif MARKERS_SIMPLE.include?(name)
      simple_marker(name, action)
    else
      raise "Neither complex nor simple marker: #{name}"
    end
  end

  private

  def on(name) = set(name, true)
  def off(name) = set(name, false)

  def start_special(name)
    @specials[name] = true
  end

  def stop_special(name)
    @specials[name] = false
  end

  def marker_header(action)
    case action
    when :on_and_start_special
      @is_endl_used = true
      @endl_marker = :header
      write(:header, :level, 1)
      start_special(:header)
    when :stop_special
      stop_special(:header)
    when :off
      @is_endl_used = false
      @endl_marker = nil
      stop_special(:header)
    when :upgrade
      lev = read(:header, :level)
      write(:header, :level, lev + 1) unless lev == 6
    else
      raise "Unknown action for marker 'header': #{action}"
    end
  end

  def simple_marker(name, action)
    raise "Unknown simple marker: #{name}" unless MARKERS_SIMPLE.include?(name)

    case action
    when :on
      on(name)
    when :off
      off(name)
    when :swap
      on?(name) ? off(name) : on(name)
    else
      raise "unknown action for marker '#{name}': #{action}"
    end
  end
end
