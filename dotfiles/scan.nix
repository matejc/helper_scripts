{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/airprint-scan";
  source = pkgs.writeScript "airprint-scan.nix" ''
#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 python3Packages.lxml

import urllib, urllib.request, urllib.error, sys, tempfile, time, ssl
from lxml import etree

# Usage: airprint-scan "filename.jpg" 600 "http://192.168.1.100:8080/eSCL/"
onam = sys.argv[1] if len(sys.argv) > 1 else None
resolution = sys.argv[2] if len(sys.argv) > 2 else None
scanner = sys.argv[3] if len(sys.argv) > 3 else None

# for printer's self signed certs
ssl._create_default_https_context = ssl._create_unverified_context

######### Get scanner configuration:

scanns = "http://schemas.hp.com/imaging/escl/2011/05/03"
pwgns = "http://www.pwg.org/schemas/2010/12/sm"

etree.register_namespace('scan', scanns)
etree.register_namespace('pwg', pwgns)

req = urllib.request.Request(url = scanner+'ScannerCapabilities')
tree = etree.parse(urllib.request.urlopen(req))
print("Scanner information:")
print(etree.tostring(tree, pretty_print=True, encoding="unicode"))

maxwid = etree.ETXPath("//{%s}MaxWidth" % scanns)(tree)[0].text
maxhei = etree.ETXPath("//{%s}MaxHeight" % scanns)(tree)[0].text

if not resolution:
    maxxr = etree.ETXPath("//{%s}MaxOpticalXResolution" % scanns)(tree)[0].text
    maxyr = etree.ETXPath("//{%s}MaxOpticalYResolution" % scanns)(tree)[0].text
    resolution = min(int(maxxr), int(maxyr))

req = etree.Element("{%s}ScanSettings" % scanns, nsmap={"pwg":pwgns})
etree.SubElement(req, "{%s}Version" % pwgns).text = "2.6"
srs = etree.SubElement(req, "{%s}ScanRegions" % pwgns)
sr = etree.SubElement(srs, "{%s}ScanRegion" % pwgns)
etree.SubElement(sr, "{%s}XOffset" % pwgns).text = "0"
etree.SubElement(sr, "{%s}YOffset" % pwgns).text = "0"
etree.SubElement(sr, "{%s}Width" % pwgns).text = maxwid
etree.SubElement(sr, "{%s}Height" % pwgns).text = maxhei
etree.SubElement(sr, "{%s}ContentRegionUnits" % pwgns).text = "escl:ThreeHundredthsOfInches"
etree.SubElement(req, "{%s}InputSource" % scanns).text = "Platen"
# Default is usually RGB24 anyway
etree.SubElement(req, "{%s}ColorMode" % scanns).text = "RGB24"
etree.SubElement(req, "{%s}XResolution" % scanns).text = str(resolution)
etree.SubElement(req, "{%s}YResolution" % scanns).text = str(resolution)

print("Our scan request:")
print(etree.tostring(req, pretty_print=True, encoding="unicode"))

# Post the request:
xml = etree.tostring(req, xml_declaration=True)
req = urllib.request.Request(url = scanner+'ScanJobs', data=xml,
        headers={'Content-Type': 'text/xml'})
location = None
try:
    import logging, urllib, sys

    hh = urllib.request.HTTPHandler()
    hsh = urllib.request.HTTPSHandler()
    hh.set_http_debuglevel(1)
    hsh.set_http_debuglevel(1)
    opener = urllib.request.build_opener(hh, hsh)
    logger = logging.getLogger()
    logger.addHandler(logging.StreamHandler(sys.stdout))
    logger.setLevel(logging.NOTSET)
    # opener.open(req)
    response = urllib.request.urlopen(req)
    print (response.info())
    location = response.info().get("Location")
except urllib.request.HTTPError as e:
    if e.code != 201:
        print(e.code)
        print(e.read())
        print(e.headers)
        print(e.msg)
        sys.exit(1)
    print(e.headers)
    location = e.headers.get("Location")

if not location:
    sys.stderr.write("No location received.\n")
    sys.exit(1)

if onam:
    of = open(onam, "wb")
else:
    of = tempfile.NamedTemporaryFile(suffix=".jpg", delete=False)
    onam = of.name
print("Scanning to: %s" % onam)


sleep_seconds = 1

while not of.closed:

    try:
        time.sleep(sleep_seconds)
        req = urllib.request.Request(url = location + "/NextDocument")
        data = urllib.request.urlopen(req)
        of.write(data.read())
        of.close()
    except urllib.error.HTTPError as e:
        if e.code == 503:
            sys.stdout.write("."*sleep_seconds)
            sys.stdout.flush()
            pass
        else:
            of.close()
            raise
    except:
        of.close()
        raise

print()
print("Scan saved to: %s" % of.name)
  '';
}
