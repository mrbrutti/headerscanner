require "../lib/HeaderScanner"


a = HeaderScanner.new

a.get :url => "www.google.com"
puts a.getheader("Server")
a.get :url => "www.amazon.com"
puts a.getheader("Server")


