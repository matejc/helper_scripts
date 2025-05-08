{ pkgs ? import <nixpkgs> {} }:
with pkgs;
buildGoModule {
    pname = "cpu";
    version = "20250418";
    src = fetchFromGitHub {
        owner = "u-root";
        repo = "cpu";
        rev = "264e2f37c69fee1e8681251a08f238078e44dcfd";
        sha256 = "sha256-a5BpwWAPYv5Fdl4HRTMi85i2siFOUHnRiyvpkWgOW/A=";
    };
    vendorHash = "sha256-VkqNLB+eHouPmDoFXVHSunRxtbiMyN9XZiWAYLp3NEc=";
    subPackages = [ "cmds/cpu" "cmds/cpud" ];
}
