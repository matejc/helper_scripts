{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/protonge-update";
  source = pkgs.writeShellScript "protonge-update.sh" ''
    set -euo pipefail

    # make temp working directory
    echo "Creating temporary working directory..."
    rm -rf /tmp/proton-ge-custom
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom

    # download tarball
    echo "Fetching tarball URL..."
    tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
    tarball_name=$(basename $tarball_url)
    echo "Downloading tarball: $tarball_name..."
    curl -# -L $tarball_url -o $tarball_name 2>&1

    # download checksum
    echo "Fetching checksum URL..."
    checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
    checksum_name=$(basename $checksum_url)
    echo "Downloading checksum: $checksum_name..."
    curl -# -L $checksum_url -o $checksum_name 2>&1

    # check tarball with checksum
    echo "Verifying tarball $tarball_name with checksum $checksum_name..."
    sha512sum -c $checksum_name
    # if result is ok, continue

    # make steam directory if it does not exist
    echo "Creating Steam directory if it does not exist..."
    mkdir -p ~/.steam/root/compatibilitytools.d

    # extract proton tarball to steam directory
    echo "Extracting $tarball_name to Steam directory..."
    tar -xf $tarball_name -C ~/.steam/root/compatibilitytools.d/
    echo "All done :)"
  '';
}]
