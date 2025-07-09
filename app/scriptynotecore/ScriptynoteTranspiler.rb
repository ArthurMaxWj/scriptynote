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
      if char == "\n" && !@ss.endl?
        result += "</br>"
      elsif SIMPLE_MD.has_value?(char) # simpel markers
        result += tag(char_to_tag(char), !@ss.switch_get(SIMPLE_MD.key(char)))
      elsif char == "\n" && @ss.endl? # endline used by marker
        if @ss.endl_marker == :header
          result += "</h1>"
          @ss.on(:header)
        end
      elsif char == "#" && !@ss.on?(:header)
        @ss.on(:header)
        result += "<h1>"
      else
        result += char
      end
    end

    result
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
    raise "no tag for: #{char}" unless TAG_LIST.has_key?(name)

    TAG_LIST[name]
  end
end
