{pkgs, ...}:
pkgs.runCommand "simple_web_server" {} ''

echo test
''
