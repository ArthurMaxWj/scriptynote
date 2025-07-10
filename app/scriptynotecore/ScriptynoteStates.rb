class ScriptynoteStates
  MARKERS = %i[bold italic underline header]
  MARKERS_COMPLEX = %i[header]

  def initialize
    @states = MARKERS.index_with(false)
    @specials = MARKERS_COMPLEX.index_with(false)
    @is_endl_used = false
    @endl_marker = nil

    @m_d_grade = 1
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


  def markerdata_header_grade = @m_d_grade

  def marker_header(action)
    case action
    when :on
      @is_endl_used = true
      @endl_marker = :header
      start_special(:header)
    when :off
      @is_endl_used = false
      @endl_marker = nil
      @m_d_grade = 1
      stop_special(:header)
    when :upgrade
      @m_d_grade += 1 unless @m_d_grade == 6
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


  private

  def marker(name)
    raise "No such state: #{name}" unless MARKERS.include?(name)

    name
  end

  def handle_complex(name, val)
    raise "Not a complex marker: #{name}" unless MARKERS_COMPLEX.include?(name)

    case name
    when :header
      if val
        @is_endl_used = true
        @endl_marker = :header
      else
        @is_endl_used = false
        @endl_marker = nil
      end
    else
      raise "Complex marker not yet supported: #{name}"
    end
  end
end
