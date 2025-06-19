{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
}:

let
  version = "2.11.10";
  mainProgram = "slippi-launcher";
in
appimageTools.wrapType2 rec {
  inherit version;
  pname = "slippi-netplay";
  src = fetchurl {
    url = "https://github.com/project-slippi/slippi-launcher/releases/download/v${version}/Slippi-Launcher-${version}-x86_64.AppImage";
    hash = "sha256-OrWd0jVqe6CzNbVRNlm2alt2NZ8uBYeHiASaB74ouW4=";
  };
  appImageContents = appimageTools.extract { inherit pname src version; };
  nativeBuildInputs = [ makeWrapper ];
  extraPkgs = pkgs: [ pkgs.curl ];
  extraInstallCommands = ''
    wrapProgram "$out/bin/${pname}" \
     --inherit-argv0
    mkdir -p "$out/share/applications"
    cp -r "${appImageContents}/$(readlink "${appImageContents}/slippi-launcher.png")" "$out/share/applications/"

    sed -e '/Icon/d' -e '/Exec/d' "${appImageContents}/slippi-launcher.desktop" > "$out/share/applications/slippi-launcher.desktop"
    echo "Icon=$out/share/applications/slippi-launcher.png" >> "$out/share/applications/slippi-launcher.desktop"
    echo "Exec=$out/bin/${pname} %U" >> "$out/share/applications/slippi-launcher.desktop"
  '';

  meta = {
    inherit mainProgram;
    homepage = "https://slippi.gg";
    description = "The way to play Slippi Online and watch replays";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
  };
}
