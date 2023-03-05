{pkgs, ...}:
pkgs.runCommand "simple_web_server" {
      propogatedBuildInputs = [
        pkgs.python3
      ];
    } ''
      mkdir -p $out/bin
      echo "${pkgs.python3}/bin/python3.10 -m http.server"  > $out/bin/simple_web_server
      chmod +x $out/bin/simple_web_server
''
