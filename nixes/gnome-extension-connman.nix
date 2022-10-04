# does not work, obviously - I am here overriding the version of current gnome shell

{ stdenv, fetchgit, which, gnome3_12, intltool, pkg-config }:
stdenv.mkDerivation rec {
  name = "gnome-extension-connman-${rev}";
  rev = "3d0d93cc36ca96b60c12257440ebb38dad53d17f";

  src = fetchgit {
    url = "https://github.com/connectivity/gnome-extension-connman";
    inherit rev;
    sha256 = "124czyrn000i8yqm324cz82xp1z3m7r109kj4imj1njxlanf0cs8";
  };

  preConfigure = ''
    ./autogen.sh
  '';

  postInstall = ''
    substituteInPlace $out/share/gnome-shell/extensions/gnome-extension-connman/metadata.json \
      --replace "\"shell-version\": [" "\"shell-version\": [ \"3.12.2\", "
  '';

  buildInputs = [ which gnome3_12.gnome_common intltool pkg-config ];
}
