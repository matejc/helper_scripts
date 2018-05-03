{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/i3_workspace";
  source = pkgs.writeScript "i3_workspace.py" ''
    #!${pkgs.python2Packages.python}/bin/python

    import subprocess
    import json
    import sys
    import os

    def usage():
        return "Usage: {0} {{prev|next|prev_on_output|next_on_output}}".format(os.path.basename(sys.argv[0]))

    if len(sys.argv) != 2:
        print usage()
        exit(1)

    direction = sys.argv[1].lower()
    if direction not in ('prev', 'next', 'prev_on_output', 'next_on_output'):
        print usage()
        exit(1)

    def find_by(workspaces, index, step = 0, output = None):
        if output != None:
            workspaces = filter(lambda w: w[u'output'] == output, workspaces)

        next_index = index + step
        min = 0
        max = len(workspaces) - 1

        if next_index < min:
            next_index = min
        elif next_index > max:
            next_index = max

        return workspaces[next_index]

    output = subprocess.check_output(["${variables.i3-msg}", "-t", "get_workspaces"])

    workspaces = json.loads(output)

    for index in range(len(workspaces)):
        workspace = workspaces[index]

        if workspace[u'focused'] == True:

            if direction == 'prev':
                print find_by(workspaces, index, -1)[u'num']
            elif direction == 'next':
                print find_by(workspaces, index, 1)[u'num']
            elif direction == 'prev_on_output':
                print find_by(workspaces, index, -1, workspace[u'output'])[u'num']
            elif direction == 'next_on_output':
                print find_by(workspaces, index, 1, workspace[u'output'])[u'num']
            else:
                print workspace[u'num']

            break

    exit(0)
  '';
}
