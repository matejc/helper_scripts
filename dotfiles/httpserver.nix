{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/httpserver";
  source = pkgs.writeScript "httpserver.py" ''
    #!${pkgs.python3Packages.python}/bin/python

    import os
    from http.server import SimpleHTTPRequestHandler, HTTPServer

    HandlerClass = SimpleHTTPRequestHandler
    ServerClass  = HTTPServer
    Protocol     = "HTTP/1.0"

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', '--address', default='127.0.0.1', help='Listen address')
    parser.add_argument('-p', '--port', type=int, default=8080, help='Listen port')
    parser.add_argument('-d', '--directory', default='.', help='Root directory')
    args = parser.parse_args()

    server_address = (args.address, args.port)
    os.chdir(args.directory)

    HandlerClass.protocol_version = Protocol
    httpd = ServerClass(server_address, HandlerClass)

    sa = httpd.socket.getsockname()
    print(f'Serving HTTP on {sa[0]}:{sa[1]} inside {args.directory} ...')
    httpd.serve_forever()
  '';
}
