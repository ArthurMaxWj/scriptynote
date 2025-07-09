class ScriptynoteStates
  MARKERS = %i[bold italic underline header]
  MARKERS_COMPLEX = %i[header]

  def initialize
    @states = MARKERS.map { |key, bal| [key, false] }.to_h
    @is_endl_used = false
    @endl_marker = nil
  end

  def on?(name)
    @states[name.to_sym]
  end

  def set(name, val)
    @states[name.to_sym] = val
    handle_complex(name, val) if MARKERS_COMPLEX.include?(name)
  end

  def on(name)
    set(name, true)
  end

  def off(name)
    set(name, false)
  end

  def switch(name)
    set(name, !on?(name))
  end

  def switch_get(name)
    switch(name)

    !on?(name)
  end

  def name_of(token)
    MARKERS.key(token)
  end

  def endl?
    @is_endl_used
  end

  def endl_marker
    @endl_marker
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
