class TranslateController < ApplicationController
  def translated
    @markdown = params[:markdown] || ''
    @result = ScriptynoteTranspiler.new.transpile(@markdown)
    puts ">>>>>"
    puts @result
  end

  def home
    @markdown = params[:markdown] || ''
  end
end
