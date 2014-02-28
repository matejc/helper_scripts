#!/usr/bin/env python

import json
import re
import subprocess
import urllib
import urllib2

WWW_SEARX = 'http://searx.scriptores.com'
BROWSER = 'vimprobable2'


def browser(args=[]):
    browser_cmd = [subprocess.check_output(["which", BROWSER]).strip()]
    if args:
        browser_cmd += args
    p = subprocess.Popen(
        browser_cmd,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    stdout, _ = p.communicate()
    return stdout.decode('utf-8').strip('\n')


def dmenu(args=[], options=[]):
    dmenu_cmd = [subprocess.check_output(["which", "dmenu"]).strip()]
    if args:
        dmenu_cmd += args
    p = subprocess.Popen(
        dmenu_cmd,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    if options:
        stdout, _ = p.communicate('\n'.join(options).encode('utf-8'))
    else:
        stdout, _ = p.communicate()
    return stdout.decode('utf-8').strip('\n')


def searx(query):
    values = {u'q': query, u'format': u'json'}

    data = urllib.urlencode(values)
    req = urllib2.Request(WWW_SEARX, data)
    response = urllib2.urlopen(req)
    json_string = response.read()
    json_dict = json.loads(json_string)

    results = []
    index = 0
    for element in json_dict['results']:
        results += [(index, element['title'], element['url'])]
        index += 1

    return results


query = dmenu(['-p', 'searx:'])
results = searx(query)
options = []
for index, title, url in results:
    options += [u'{} - {} [{}]'.format(index, title, url)]

target = dmenu(['-l', '10'], options)

browser(
    [results[int(re.match('(\d+)\ \- ', target).groups()[0])][2], ]
)
