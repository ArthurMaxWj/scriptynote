class TranslateController < ApplicationController
  def translated
    text = params[:text] || ''
    @result = ScriptynoteTranspiler.new.transpile(text)
    puts ">>>>>"
    puts @result
  end

  def home
  end
end
