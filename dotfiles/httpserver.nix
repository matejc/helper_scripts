{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/httpserver";
  source = pkgs.writeScript "httpserver.py" ''
    #!${pkgs.python27Packages.python}/bin/python

    import sys
    import BaseHTTPServer
    from SimpleHTTPServer import SimpleHTTPRequestHandler

    HandlerClass = SimpleHTTPRequestHandler
    ServerClass  = BaseHTTPServer.HTTPServer
    Protocol     = "HTTP/1.0"

    if sys.argv[1:]:
        host = sys.argv[1]
    else:
        host = "127.0.0.1"

    if sys.argv[2:]:
        port = int(sys.argv[2])
    else:
        port = 8000

    server_address = (host, port)

    HandlerClass.protocol_version = Protocol
    httpd = ServerClass(server_address, HandlerClass)

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    httpd.serve_forever()
  '';
}
