require 'socket'

class HTTPBasic
  
  attr_reader :header, :response, :status, :reason, :headers
  attr_accessor :url, :port, :protocol, :body, :extheader
  
	def initialize(url=nil, port=nil, protocol=nil, body=nil, extheader=nil)
      @url = url
      @port = port.nil? ? 80 : port
      @protocol = protocol.nil? ? "HTTP/1.0" : protocol
      @body = body.nil? ? nil : body
      @extheader = extheader.nil? ? {} : extheader 
	end
  
  ##
  # This will allow us to perform direct method execution.
  # puts HTTPBasic.get(:url => "www.google.com.ar")
  #
  
  class << self
    %w(head get post put delete options trace connect propfind proppatch).each do |method|
        eval <<-EOD
          def #{method}(args)
            new.#{method}(args)
          end
        EOD
    end
  end
  
  %w(head get post put delete options trace connect propfind proppatch).each do |method|
      eval <<-EOD
        def #{method}(args)
          do_request("#{method.upcase}", args[:url] || @url, args[:port] || @port, 
                        args[:body] || nil, args[:protocol]|| @protocol, args[:extheader] || {})
        end
      EOD
  end
  
  def propfind(args)
    do_request("PROPFIND", args[:url] || @url, args[:port] || @port, 
       args[:body] || nil, args[:protocol]|| @protocol, args[:extheader] || {'Depth' => '0'})
  end
  
  def handcraft_request(url, port, request_string)
    begin
      request = TCPSocket.new(url, port)
      req = request_string
      request.print req
      @header, @response = request.gets(nil).split("\r\n\r\n")
    rescue
      puts "error: #{$!}"
    end
    parseheader
    [@header, @response]
  end
  
  def getheader(key)
    @headers.fetch(key)
  end
  
  private
  
  def do_request(method, url, port, body, protocol, extheader)
    begin
      r_url = url.match(/http:\/\//) ? url[/http.*:\/\/[._0-9A-Za-z-]*/].split("//")[1] : url[/^[._0-9A-Za-z-]*/]
      r_path = url.match(/http:\/\//) ? url.split(/http.*:\/\/[._0-9A-Za-z-]*\//)[1] : url.split(/^[._0-9A-Za-z-]*\//)[1]
      request = TCPSocket.new(r_url, port)
      req = "#{method} /#{r_path unless nil} #{protocol}\n"
      extheader.each_pair {|k,v| req << "#{k}:#{v}\n"} unless extheader.empty?    
      req << "\n"
      req << "#{body}" unless body.nil?
      request.print req
      @header, @response = request.gets(nil).split("\r\n\r\n")
      request.close
    rescue
      puts "error: #{$!}"
    end
    parseheader
    [@header, @response]
  end
  
  def parseheader
    @headers = {}
    @header.split("\r\n").each_with_index do |h,idx|
      if idx == 0
        protocol, @status, @reason = h.split(' ') 
      else
        key,value = h.split(': ')
        @headers[key] = value
      end
    end
  end
end