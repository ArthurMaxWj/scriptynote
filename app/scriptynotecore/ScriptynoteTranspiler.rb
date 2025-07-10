class ScriptynoteTranspiler
  TAG_LIST = {
    bold: "b",
    italic: "i",
    underline: "u"
  }

  SIMPLE_MD = {
    bold: "*",
    italic: "/",
    underline: "_"
  }

  def initialize
    @ss = ScriptynoteStates.new
  end

  def transpile(text)
    result = ""

    text.each_char do |char|
      if @ss.special?
        result += handle_special(char)
      else
        result += handle_normal(char)
      end
    end

    result
  end

  def handle_special(char)
    if char != "#" && @ss.inside_special?(:header) # resolve header
      @ss.marker(:header, :stop_special)
      num = @ss.read(:header, :level)

      "<h#{num}>#{char}"
    elsif char == "#" && @ss.inside_special?(:header) # upgrade header
      @ss.marker(:header, :upgrade)
      ""
    else
      raise "No more known specials left"
    end
  end

  def handle_normal(char)
    if char == "\n" && !@ss.endl?
      "<br>"
    elsif SIMPLE_MD.has_value?(char) # simple markers
      mark = SIMPLE_MD.key(char)
      @ss.marker(mark, :swap)

      tag(char_to_tag(char), @ss.on?(mark))
    elsif char == "\n" && @ss.endl? # if endline used by marker
      if @ss.endl_marker == :header
        num = @ss.read(:header, :level)
        @ss.marker(:header, :off)

        "</h#{num}>"
      else
        ""
      end
    elsif char == "#"
      @ss.marker(:header, :on_and_start_special)
      ""
    else # not a marker-special character
      char
    end
  end

  private

  def tag(t, should_open)
    if should_open
      "<#{t}>"
    else
      "</#{t}>"
    end
  end

  def char_to_tag(char)
    name = SIMPLE_MD.key(char)
    raise "No tag for: #{char}" unless TAG_LIST.has_key?(name)

    TAG_LIST[name]
  end
end
