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

    def title(cmd = "{current_job}"):
      line = "{short_cwd}"
      if cmd is not None:
        return line + " " + cmd
      else:
        return line

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

    $PROMPT = prompt()
    $RIGHT_PROMPT = rprompt()
    $TITLE = title()
    $COMPLETIONS_CONFIRM = True
    $BASH_COMPLETIONS = "${bash_completion}"
    $CASE_SENSITIVE_COMPLETIONS = False
    $VC_BRANCH_TIMEOUT = 0.5
    $PERL5LIB = "${pkgs.git}/share/perl5" + ":" + $PERL5LIB
  '';
}
