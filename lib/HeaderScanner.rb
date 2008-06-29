#
#  Headermethods.rb
#  HeaderScanner << HTTPBasic
#
#  Created by FreedomCoder on 4/21/08.
#  Copyright (c) 2008 FreedomCoder Labs. All rights reserved.
#

=begin 
TODO List for HeaderScanner Library

Test to see if the webserver is working as a web proxy 
For example 
do a

GET http://URL/ HTTP/1.0   o  GET HTTP://URL:PORT/ HTTP/1.0

if I get a response of  HTTP/1.1 200 OK .. 
it should return that we can use the web server as a web proxy 
Another way we could check for a web proxy is to use the actual command CONNECT

CONNECT URL:PORT HTTP/1.0

if we get something close to HTTP/1.1 Connection established ...  eureka ! 
If we are able to establish a connection , usually on port 443 , this will allow us to proxy 
comms through that port meaning that we can perform tests on local IP address 

GET http://192.168.1.1:22 HTTP/1.1

HTTP/1.1 200 OK 
Connection: close

SSH-20.-OpenSSH_4.2.....

if we get a 502 bad gateway the port is close.
if we get a 502 proxy error means that we do not have a banner but the port IS open.

=end

require 'rubygems'
require "HTTPBasic.rb"
require "Colorize.rb"

class HeaderScanner < HTTPBasic
  	
	#Finds internal IP disclosure
	def find_internal_ip
	  (@header+@response).scan(/10(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}|172.(?:1[6-9]|2[0-9]?\d|30|31)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){2}|192.168(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){2}/)
	end
	
	#Returns Server information on Header
	def find_server_disclosure
	  @header.scan(/Server:.*$/)
  end
  
  #Finds a given string or regex
  def find_string(string)
    @header.scan(string)
  end
  
  #Checks for Basic Authentication
  def check_basic_auth
    @header.match(/WWW-Authenticate/).nil? ? false : true
  end
    
  def check_proxy_by_connect(url=nil, port=nil, protocol=nil, body=nil, extheader=nil)
    do_connect(url || @url, port || @port, protocol || @protocol, body || @body, extheader || @extheader)
    response.to_s.match(/established/) != nil ? response.to_s : response.to_s
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

