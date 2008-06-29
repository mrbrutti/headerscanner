class Colorize
  
  @STYLE = { :default   =>  "\33[0m", 
            :bold       =>  "\33[1m", 
            :underline  =>  "\33[4m",
            :blink      =>  "\33[5m",
            :reverse    =>  "\33[7m",
            :concealed  =>  "\33[8m",
            :black      =>  "\33[30m",
            :red        =>  "\33[31m",
            :green      =>  "\33[32m",
            :yellow     =>  "\33[33m",
            :blue       =>  "\33[34m",
            :magenta    =>  "\33[35m",
            :cyan       =>  "\33[36m",
            :white      =>  "\33[37m",
            :on_black   =>  "\33[40m",
            :on_red     =>  "\33[41m",
            :on_green   =>  "\33[42m",
            :on_yellow  =>  "\33[43m",
            :on_blue    =>  "\33[44m",
            :on_magenta =>  "\33[45m",
            :on_cyan    =>  "\33[46m",
            :on_white   =>  "\33[47m" }
  
  def self.pretty_print(html_text)
    parse(html_text)
  end
  
  private
  
  def parse(text)
    puts "test" + text
  end


  
end