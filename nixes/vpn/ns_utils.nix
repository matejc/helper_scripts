{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  nsExecC = writeText "ns_exec.c" ''
    #define _GNU_SOURCE
    #include <fcntl.h>
    #include <sched.h>
    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>

    #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                           } while (0)

    int
    main(int argc, char *argv[])
    {
      int fd;

      if (argc < 3) {
         fprintf(stderr, "%s /proc/PID/ns/FILE cmd args...\n", argv[0]);
         exit(EXIT_FAILURE);
      }

      fd = open(argv[1], O_RDONLY);  /* Get file descriptor for namespace */
      if (fd == -1)
        errExit("open");

      if (setns(fd, 0) == -1)        /* Join that namespace */
        errExit("setns");

      execvp(argv[2], &argv[2]);     /* Execute a command in namespace */
      errExit("execvp");
    }
  '';

  nsSuC = writeText "ns_su.c" ''
    #define _GNU_SOURCE
    #include <fcntl.h>
    #include <sched.h>
    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <grp.h>

    #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                           } while (0)

    int main(int argc, char *argv[])
    {
      int err;

      if (argc < 4) {
         fprintf(stderr, "%s <uid> <gid> <cmd> [args...]\n", argv[0]);
         exit(EXIT_FAILURE);
      }

      unshare(CLONE_NEWUSER);

      int fd;
      size_t map_len;

      fd=open("/proc/self/setgroups",O_WRONLY);
      write(fd,"deny",4);
      close(fd);

      gid_t gid = atoi(argv[2]);
      err = setgid(gid);
      if (err == -1)
        errExit("setgid");

      uid_t uid = atoi(argv[1]);
      err = setuid(uid);
      if (err == -1)
        errExit("setuid");

      execvp(argv[3], &argv[3]);
      errExit("execvp");
    }
  '';

  nsUserC = writeText "ns_user.c" ''
    #define _GNU_SOURCE
    #include <fcntl.h>
    #include <sched.h>
    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <grp.h>

    #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                           } while (0)

    int main(int argc, char *argv[])
    {
      int err;

      if (argc < 2) {
         fprintf(stderr, "%s <cmd> [args...]\n", argv[0]);
         exit(EXIT_FAILURE);
      }

      unshare(CLONE_NEWUSER);

      int fd;
      fd=open("/proc/self/uid_map",O_WRONLY);
      write(fd,"200000 0 1",10);
      close(fd);
      errExit("uid_map(200000:0)");

      fd=open("/proc/self/uid_map",O_WRONLY);
      write(fd,"1000 1000 1",11);
      close(fd);
      errExit("uid_map(1000:1000)");

      fd=open("/proc/self/gid_map",O_WRONLY);
      write(fd,"200000 0 1\n1000 1000 1",22);
      close(fd);
      errExit("gid_map");

      execvp(argv[1], &argv[1]);
      errExit("execvp");
    }
  '';

  nsUtils = runCommand "ns_utils" {
    buildInputs = [ stdenv.cc.cc binutils ];
  } ''
    mkdir -p $out/bin
    gcc -o $out/bin/ns_exec -B${stdenv.cc.libc}/lib ${nsExecC}
    gcc -o $out/bin/ns_su -B${stdenv.cc.libc}/lib ${nsSuC}
    gcc -o $out/bin/ns_user -B${stdenv.cc.libc}/lib ${nsUserC}
  '';
in
  nsUtils
