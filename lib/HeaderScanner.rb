#
#  Headermethods.rb
#  HeaderScanner << HTTPBasic
#
#  Created by FreedomCoder on 4/21/08.
#  Copyright (c) 2008 FreedomCoder Labs. All rights reserved.
#  GPL 3.0 



require 'rubygems'
require "HTTPBasic.rb"
require "Colorize.rb"

class HeaderScanner < HTTPBasic
  	
	#Finds internal IP disclosure whole 
	def find_internal_ip
	  self.to_s.scan(/10(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}|172.(?:1[6-9]|2[0-9]?\d|30|31)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){2}|192.168(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){2}/)
	end
	
	#Finds a given string or regex
  def find_string(string)
    self.to_s.scan(string)
  end
  
  ## HEADER CHECKS
	#Returns Server information on Header
	def find_server_disclosure
	  @header.scan(/Server:.*$/) unless @header.nil?
  end
  
  def check_for_proxy
    @header.scan(/Via:.*$/) unless @header.nil?
  end
  
  #Checks for Basic Authentication
  def check_basic_auth
    @header.match(/WWW-Authenticate/).nil? ? false : true
  end
  
  ## PROXY CHECKS
  def check_proxy_by_connect(url=nil, port=nil, protocol=nil, body=nil, extheader=nil)
    do_connect(url || @url, port || @port, protocol || @protocol, body || @body, extheader || @extheader).to_s.match(/established/)
  end
  
  private
  
  def do_connect(url, port, protocol, body, extheader)
    begin
      r_url = url.match(/http:\/\//) ? url[/http.*:\/\/[._0-9A-Za-z-]*/].split("//")[1] : url[/^[._0-9A-Za-z-]*/]
      request = TCPSocket.new(r_url, port)
      req = "CONNECT #{url}:#{port} #{protocol}\n"
      extheader.each_pair {|k,v| req << "#{k}:#{v}\n"} unless extheader.empty?    
      req << "\n"
      req << "#{body}" unless body.nil?
      request.print req
      @header, @response = request.gets(nil).split("\r\n\r\n")
      request.close
    rescue
      puts "error: #{$!}"
    end
    [@header, @response]
  end
  
end

