#!/usr/bin/python3

import os
import sys
import datetime
import json
import subprocess
from time import sleep
from pydbus import SessionBus
from glob import glob


BUS = SessionBus()
LAYOUT = BUS.get(bus_name='org.way-cooler', object_path='/org/way_cooler/Layout')


def main():
    while True:
        layout = json.loads(LAYOUT.Debug())
        workspaces = get_workspaces(layout)
        workspaces.sort()
        active_workspace = ""
        try:
            active_workspace = LAYOUT.ActiveWorkspace()
        except Exception:
            pass
        workspaces = " ".join(workspaces)
        workspaces = format_workspaces(layout, workspaces, active_workspace)
        funcs = [workspaces + "%{c}",
                 lambda: get_time() + "%{r}",
                 my_get_temp,
                 my_get_battery]
        outputs = []
        for func in funcs:
            if type(func) == str:
                outputs += [func]
                continue
            outputs += [func()]
        print(" • ".join(outputs))
        sys.stdout.flush()
        sleep(1)


def get_workspaces(layout_json):
    """Gets the workspace names from the layout json"""
    if not layout_json:
        return []
    outputs = layout_json['Root']
    workspaces = []
    for output in outputs:
        workspaces.extend(output['Output'])
    return [list(workspace.keys())[0].split('Workspace')[1].strip()
            for workspace in workspaces]


def get_time():
    return datetime.datetime.now().strftime('%a, %-dth of %b - %H:%M')


def get_battery():
    try:
        [path] = glob("/sys/class/power_supply/BAT?/capacity")
        with open(path, "r") as f:
            bat = f.readlines()
            result = bat[0].strip() + "% Battery"
    except Exception:
        result = ""
    return result


def my_get_temp():
    try:
        path = os.path.expanduser("~/.temp1_input")
        with open(path, "r") as f:
            temp = f.read()
            result = str(int(temp.strip())/1000) + "°C"
    except Exception:
        result = ""
    return result


def my_get_battery():
    try:
        bat = subprocess.check_output("batstatus")
        result = bat.decode().strip() + "%"
    except Exception:
        result = ""
    return result


def format_workspaces(layout, workspaces, active_workspace):
    workspaces = "  " + workspaces.replace(" ", "  ") + "  "
    # argv[3] = selected workspace color other workspace
    # argv[2] = background color
    # argv[1] = selected workspace color
    on_other_monitor = is_on_other_monitor(layout, active_workspace)
    selected_color = sys.argv[3] if on_other_monitor else sys.argv[1]
    active_workspace_format = (
            "%{F" + selected_color + "} " + active_workspace.strip() + "%{F-} %{B" + sys.argv[2] + "}")
    workspaces = workspaces.replace(" " + active_workspace + " ",
                                    active_workspace_format)
    return workspaces


def is_on_other_monitor(layout, active_workspace) -> bool :
    first_output = layout['Root'][0]['Output']
    for workspace in first_output:
        if workspace.get("Workspace " + active_workspace):
            return False
    return True


if __name__ == "__main__":
    main()
