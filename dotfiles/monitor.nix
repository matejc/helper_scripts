{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/monitor";
  source = pkgs.writeScript "monitor" ''
    #!${pkgs.python3Packages.python}/bin/python
    import subprocess
    import re

    mouselocation = subprocess.check_output(['${pkgs.xdotool}/bin/xdotool', 'getmouselocation']).decode('utf-8')
    mouse = {
        'x': int(mouselocation.split(' ')[0].split(':')[1]),
        'y': int(mouselocation.split(' ')[1].split(':')[1])
    }

    results = []
    for line in subprocess.check_output('${pkgs.xorg.xrandr}/bin/xrandr').decode('utf-8').split('\n'):
        words = line.split(' ')
        if len(words) < 2:
            continue
        if words[1] == 'connected':
            gs = [s for s in words if re.match(r'[0-9]+x[0-9]+\+[0-9]+\+[0-9]+', s)]
            g = "" if len(gs) == 0 else gs[0]
            data = [s.split('x') for s in g.split('+')]
            entry = {
                'name': words[0],
                'state': words[1],
                'index': len(results),
                'width': int(data[0][0]),
                'height': int(data[0][1]),
                'x': int(data[1][0]),
                'y': int(data[2][0]),
                'mouse': False
            }
            entry['mouse'] = entry['x'] < mouse['x'] and \
                entry['x']+entry['width'] > mouse['x'] and \
                entry['y'] < mouse['y'] and \
                entry['y']+entry['height'] > mouse['y']
            results += [entry]


    def monitor_sort(current):
        y_score = 1
        x_score = 1
        for r in results:
            if current['index'] == r['index']:
                continue
            if current['y'] > r['y']:
                y_score += 2
            if current['x'] > r['x']:
                x_score += 1
        return y_score * x_score


    monitor = next((i for i, x in enumerate(results) if x['mouse']), 0)

    entry = results[(monitor + 1) % len(results)]

    subprocess.Popen(['${pkgs.xdotool}/bin/xdotool', 'mousemove', str((entry['width']/2)+entry['x']), str((entry['height']/2)+entry['y'])])
  '';
}
