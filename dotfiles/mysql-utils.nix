{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/mysql-create-db";
  source = pkgs.writeScript "mysql-create-db.sh" ''
    #!${pkgs.stdenv.shell}

    EXPECTED_ARGS=4
    E_BADARGS=65

    if [ $# -ne $EXPECTED_ARGS ]
    then
      echo "Usage: $0 dbhost dbname dbuser dbpass"
      exit $E_BADARGS
    fi

    MYSQL="${pkgs.mysql}/bin/mysql"

    Q1="CREATE DATABASE IF NOT EXISTS $2 CHARACTER SET utf8 COLLATE utf8_general_ci;"
    Q2="GRANT USAGE ON *.* TO $3 IDENTIFIED BY '$4';"
    Q3="GRANT ALL PRIVILEGES ON $2.* TO $3;"
    SQL="$Q1$Q2$Q3"

    $MYSQL -h$1 -uroot -p -e "$SQL"
  '';
} {
  target = "${variables.homeDir}/bin/mysql-convert-to-utf8";
  source = pkgs.writeScript "mysql-convert-to-utf8.sh" ''
    #!${pkgs.stdenv.shell}

    EXPECTED_ARGS=2
    E_BADARGS=65

    if [ $# -ne $EXPECTED_ARGS ]
    then
      echo "Usage: $0 dbhost dbname"
      exit $E_BADARGS
    fi

    MYSQL="${pkgs.mysql}/bin/mysql"

    Q1="ALTER DATABASE $2 CHARACTER SET utf8 COLLATE utf8_general_ci;"
    SQL="$Q1"

    echo -n Password:
    read -s PASSWORD
    echo

    SQLSATTEMENTS=`$MYSQL -h$1 -uroot -p"$PASSWORD" --database=$2 -B -N -e "SHOW TABLES" | ${pkgs.gawk}/bin/awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci; SET foreign_key_checks = 1; "}'`

    echo $SQLSATTEMENTS

    echo -n Press enter to continue
    read

    $MYSQL -h$1 -uroot -p"$PASSWORD" -e "$SQL"

    echo $SQLSATTEMENTS | $MYSQL -h$1 -uroot -p"$PASSWORD" --database=$2
  '';
} {
  target = "${variables.homeDir}/bin/mysql-backup";
  source = pkgs.writeScript "mysql-backup.sh" ''
    #!${pkgs.stdenv.shell}

    EXPECTED_ARGS=2
    E_BADARGS=65

    if [ $# -ne $EXPECTED_ARGS ]
    then
      echo "Usage: $0 dbhost dbname"
      exit $E_BADARGS
    fi

    ${pkgs.mysql}/bin/mysqldump --opt -uroot -p -h$1 $2 > backup-`date +%s`.sql
  '';
} {
  target = "${variables.homeDir}/bin/mysql-restore";
  source = pkgs.writeScript "mysql-restore.sh" ''
    #!${pkgs.stdenv.shell}

    EXPECTED_ARGS=3
    E_BADARGS=65

    if [ $# -ne $EXPECTED_ARGS ]
    then
      echo "Usage: $0 dbhost dbname file"
      exit $E_BADARGS
    fi

    ${pkgs.mysql}/bin/mysql -uroot -p -h$1 $2 < $3
  '';
}]
