{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  rootlesskit = buildGoModule rec {
    pname = "rootlesskit";
    version = "1.0.1";
    src = fetchFromGitHub {
      owner = "rootless-containers";
      repo = "rootlesskit";
      rev = "v${version}";
      sha256 = "sha256-wdg3pYsWHAEzQHy5LZYp0q9sOn7dmtcwOn94/0wYDa0=";
    };
    runVend = true;
    vendorSha256 = "sha256-OKqF9EutZP+6CFtANpNt21hGsz6GxuXcoaEqPKnoqeo=";
  };

  script = writeScript "script.sh" ''
    #!${pkgs.stdenv.shell}
    dig google.com
    ip route
    ns_su id
    id
    ls -lah /
    date
  '';

  uid = 1000;
  gid = 100;

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

    int
    main(int argc, char *argv[])
    {
      int err;

      if (argc < 2) {
         fprintf(stderr, "%s cmd args...\n", argv[0]);
         exit(EXIT_FAILURE);
      }

      gid_t gid = ${toString gid};
      err = setgid(gid);
      if (err == -1)
        errExit("setgid");

      setgroups(0, NULL);

      uid_t uid = ${toString uid};
      err = setuid(uid);
      if (err == -1)
        errExit("setuid");

      execvp(argv[1], &argv[1]);
      errExit("execvp");
    }
  '';

  nsUtils = runCommand "ns_utils" {
    buildInputs = [ stdenv.cc.cc binutils ];
  } ''
    mkdir -p $out/bin
    gcc -o $out/bin/ns_su -B${stdenv.cc.libc}/lib ${nsSuC}
  '';
in
  mkShell {
    buildInputs = [ rootlesskit slirp4netns dnsutils nsUtils ];
    shellHook = ''
      exec rootlesskit --pidns --cgroupns --utsns --ipcns --net=slirp4netns --copy-up=/etc \
        --disable-host-loopback ${script}
    '';
  }
