{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/jira";
  source = pkgs.writeScript "jira.sh" ''
  #!${pkgs.stdenv.shell} -xe
  export JAVA_HOME="${pkgs.oraclejre}"
  export CFG_HOME="${variables.homeDir}/.jira"
  export CATALINA_BASE="${variables.homeDir}/.jira/catalina"
  export JIRA_HOME="${variables.homeDir}/.jira/home"

  mkdir -p $CATALINA_BASE/{logs,work,temp,deploy,conf}

  mkdir -p /run/atlassian-jira
  ln -sf $CATALINA_BASE/{logs,work,temp,conf/server.xml} /run/atlassian-jira
  ln -sf $CATALINA_BASE /run/atlassian-jira/home

  chown -R ${variables.user} $CFG_HOME

  sed -e 's,port="8080",port="8888" address="127.0.0.1",' \
    ${pkgs.atlassian-jira}/conf/server.xml.dist > $CATALINA_BASE/conf/server.xml

  ${pkgs.atlassian-jira}/bin/start-jira.sh -fg
  '';
}
