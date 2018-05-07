{ variables, config, pkgs, lib }:
let
  bash_completion = pkgs.writeScript "bash_completion" ''
    . ${pkgs.bash-completion}/share/bash-completion/bash_completion
    for p in $NIX_PROFILES; do
      for m in "$p/etc/bash_completion.d/"*; do
        . $m
      done
    done
  '';
in {
  target = "${variables.homeDir}/.xonshrc";
  source = pkgs.writeScript "xonshrc" ''
    import json
    from os import listdir
    from os.path import join
    from operator import itemgetter
    from prompt_toolkit.keys import Keys
    from prompt_toolkit.filters import Condition
    from prompt_toolkit.completion import Completion
    from prompt_toolkit.document import Document

    hist_dir = __xonsh_env__['XONSH_DATA_DIR']

    # docs http://python-prompt-toolkit.readthedocs.io/en/master/pages/reference.html

    $PATH += ["${variables.homeDir}/bin", "/run/wrappers/bin", "${variables.homeDir}/.nix-profile/bin", "/nix/var/nix/profiles/default/bin", "/run/current-system/sw/bin", "/etc/profiles/per-user/${variables.user}/bin"]

    history_search_state = {
      'text': None,
      'history': []
    }

    def battery():
      batstatus = int($(batstatus))
      color = "{YELLOW}"
      if batstatus < 30:
        color = "{RED}"
      elif batstatus > 60:
        color = "{GREEN}"
      return color + str(batstatus) + "%{NO_COLOR}"

    def temperature():
      temp = int(int($(cat ~/.temp1_input)) / 1000)
      color = "{YELLOW}"
      if temp > 60:
        color = "{RED}"
      elif temp < 40:
        color = "{GREEN}"
      return color + str(temp) + "°C{NO_COLOR}"

    def prompt(postString = None):
      lineOne = "╭─{env_name:{} }{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE}{cwd: {}}{BOLD_WHITE}{gitstatus: [{}]}{NO_COLOR}"
      lineTwo = "╰─{BOLD_BLUE}{prompt_end}{NO_COLOR} "
      if postString is not None:
        return lineOne + postString + '\n' + lineTwo
      else:
        return lineOne + '\n' + lineTwo

    def rprompt(seconds = 0, telepresence_pod = None, rtn = 0):
      postString = ""
      if seconds > 1:
        postString += ' {BOLD_WHITE}[{BOLD_BLUE}'+str(seconds)+'s{BOLD_WHITE}]{NO_COLOR}'

      if telepresence_pod is not None:
        postString += ' {BOLD_WHITE}[{RED}telepresence{BOLD_WHITE}]{NO_COLOR}'

      if rtn is not 0:
        postString += ' {BOLD_WHITE}[{BOLD_RED}' + str(rtn) + '↵{BOLD_WHITE}]{NO_COLOR}'

      return postString + " [" + battery() + "/" + temperature() + "]"

    def title(cmd = "{current_job: {}}"):
      line = "{short_cwd}"
      prefix = ""
      try:
        prefix = $TMUX_SESSION_NAME + " "
      except:
        pass
      if cmd is not None:
        return prefix + line + cmd
      else:
        return prefix + line

    @events.on_precommand
    def preexec(cmd):
      import time
      global timer
      timer = time.time()
      $TITLE = title()

    @events.on_postcommand
    def postexec(cmd, rtn, out, ts):
      import time

      seconds = int(time.time() - timer)

      telepresence_pod = None
      try:
        telepresence_pod = $TELEPRESENCE_POD
      except:
        pass

      $PROMPT = prompt()
      $RIGHT_PROMPT = rprompt(seconds=seconds, telepresence_pod=telepresence_pod, rtn=rtn)
      $TITLE = title()

    def del_duplicates(seq):
      seen = set()
      seen_add = seen.add
      return [x for x in seq if not (x in seen or seen_add(x))]

    def getHistory(text = ""):
      files = [join(hist_dir,f) for f in listdir(hist_dir)
               if f.startswith('xonsh-') and f.endswith('.json')]

      fileHist = [json.load(open(f))['data']['cmds'] for f in files]

      commands = [(c['inp'].replace('\n', ""), c['ts'][0])
                  for commands in fileHist for c in commands if c]

      commands.sort(key=itemgetter(1))

      numOfCommands = len(commands)
      digits = len(str(numOfCommands))

      return [c[0] for c in commands if c[0].find(text) != -1]

    @events.on_ptk_create
    def custom_keybindings(bindings, **kw):
      handler = bindings.registry.add_binding

      @Condition
      def has_text(cli):
        return len(cli.current_buffer.document.text) != 0

      @handler(Keys.ControlR, filter=has_text)
      def history_search_activate(event):
        history_search_state['text'] = event.cli.current_buffer.document.text
        history_search_state['history'] = del_duplicates(getHistory(text=history_search_state['text']))
        history_search_state['history'].reverse()
        completions = [Completion(text=t, start_position=(len(history_search_state['text'])*-1)) for t in history_search_state['history']]
        event.cli.current_buffer.set_completions(completions)

    $PROMPT = prompt()
    $RIGHT_PROMPT = rprompt()
    $TITLE = title()
    $COMPLETIONS_CONFIRM = True
    $BASH_COMPLETIONS = "${bash_completion}"
    $CASE_SENSITIVE_COMPLETIONS = False
    $VC_BRANCH_TIMEOUT = 0.5
    $PERL5LIB = "${pkgs.git}/share/perl5"
    $XONSH_SHOW_TRACEBACK = True
    $COMPLETIONS_DISPLAY = "single"
    $AUTO_CD = True
  '';
}
