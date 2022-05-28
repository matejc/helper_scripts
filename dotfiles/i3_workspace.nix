{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/i3_workspace";
  source = pkgs.writeScript "i3_workspace.py" ''
    #!${pkgs.python2Packages.python}/bin/python

    import subprocess
    import json
    import sys
    import os

    def usage():
        return "Usage: {0} [--skip,--notify] {{prev|next|prev_on_output|next_on_output}}".format(os.path.basename(sys.argv[0]))

    if len(sys.argv) < 2:
        print usage()
        exit(1)

    direction = 'next'
    skip = False
    notify = False

    for i in range(1, len(sys.argv)):
        option = sys.argv[i].lower()
        if option in ('prev', 'next', 'prev_on_output', 'next_on_output'):
            direction = option
        elif option == '--notify':
            notify = True
        elif option == '--skip':
            skip = True
        else:
            print usage()
            exit(1)

    def find_by(workspaces, current, step, output = None, skip = True):
        others = []
        if output != None:
            workspaces = filter(lambda w: w[u'output'] == output, workspaces)
            otherworkspaces = filter(lambda w: w[u'output'] != output, workspaces)
            others = map(lambda w: w[u'num'], otherworkspaces)

        existing = map(lambda w: w[u'num'], workspaces)

        othersnext = filter(lambda w: w > current, others)
        othersprev = [0] + filter(lambda w: w < current, others)

        next = current + step
        first = 1
        last = max(existing)

        if output != None:
            first = max(othersprev) + 1
            last = next if len(othersnext) == 0 else min(othersnext) - 1

        if skip:
            r = []
            if step > 0:
                r = range(first, last+1)
            elif step < 0:
                r = range(next-1, first-1, -1)
            for i in r:
                if next in existing:
                    break
                next += step

        if current == last and step > 0:
            next = last + step
        elif next < first:
            next = first
        elif next > last:
            next = last

        return next

    output = subprocess.check_output(["${variables.i3-msg}", "-t", "get_workspaces"])

    workspaces = json.loads(output)

    for index in range(len(workspaces)):
        workspace = workspaces[index]

        if workspace[u'focused'] == True:
            current = workspace[u'num']
            result = current

            if direction == 'prev':
                result = find_by(workspaces, current, -1, skip=skip)
            elif direction == 'next':
                result = find_by(workspaces, current, 1, skip=skip)
            elif direction == 'prev_on_output':
                result = find_by(workspaces, current, -1, workspace[u'output'], skip)
            elif direction == 'next_on_output':
                result = find_by(workspaces, current, 1, workspace[u'output'], skip)

            if notify:
              subprocess.call(["${pkgs.libnotify}/bin/notify-send", "-a", "workspace", "-t", "500", "Workspace: "+str(result)])
            print result

            break

    exit(0)
  '';
} {
  target = "${variables.homeDir}/bin/i3_query";
  source = pkgs.writeScript "i3_query.py" ''
    #!${pkgs.python2Packages.python}/bin/python

    import subprocess
    import json
    import sys
    import os


    def usage():
        return "Usage: {0} <key> <value>".format(os.path.basename(sys.argv[0]))


    if len(sys.argv) != 3:
        print usage()
        exit(1)


    def search_rec(obj, key, value):
        typeof = type(obj)

        if typeof == dict:
            if obj.get(key) == value:
                return obj
            else:
                for k in obj:
                    r = search_rec(obj.get(k), key, value)
                    if r is not None:
                        return r
        elif typeof == list:
            for v in obj:
                r = search_rec(v, key, value)
                if r is not None:
                    return r


    output = subprocess.check_output(["${variables.i3-msg}", "-t", "get_tree"])
    tree = json.loads(output)

    print json.dumps(search_rec(tree, sys.argv[1], sys.argv[2]))

    exit(0)
  '';
}]
