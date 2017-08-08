{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/mysql-create-db";
  source = pkgs.writeScript "mysql-create-db.sh" ''
    #!${pkgs.stdenv.shell}

    EXPECTED_ARGS=4
    E_BADARGS=65
    MYSQL="${pkgs.mysql}/bin/mysql"

    Q1="CREATE DATABASE IF NOT EXISTS $2;"
    Q2="GRANT USAGE ON *.* TO $3 IDENTIFIED BY '$4';"
    Q3="GRANT ALL PRIVILEGES ON $2.* TO $3;"
    SQL="$Q1$Q2$Q3"

    if [ $# -ne $EXPECTED_ARGS ]
    then
      echo "Usage: $0 dbhost dbname dbuser dbpass"
      exit $E_BADARGS
    fi

    $MYSQL -h$1 -uroot -p -e "$SQL"
  '';
}
