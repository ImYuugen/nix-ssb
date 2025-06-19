{
  appimageTools,
  fetchzip,
  lib,
  makeWrapper,
}:

let
  version = "3.4.6";
  raw = fetchzip {
    url = "https://github.com/project-slippi/Ishiiruka/releases/download/v${version}/FM-Slippi-${version}-Linux.zip";
    stripRoot = false;
    hash = "sha256-yjHoLOQpEXgjWMHxDiHYUmOP3e1zt3j13Gywx/PRe3w=";
  };
  mainProgram = "Slippi_Online-x86_64.AppImage";
in
appimageTools.wrapType2 rec {
  inherit version;
  pname = "slippi-netplay";
  src = "${raw}/${mainProgram}";
  nativeBuildInputs = [ makeWrapper ];
  extraPkgs = pkgs: [ pkgs.curl ];
  extraInstallCommands = ''
    wrapProgram "$out/bin/${pname}" \
     --inherit-argv0
  '';
  passthru.raw-zip = raw;

  meta = {
    inherit mainProgram;
    homepage = "https://github.com/project-slippi/Ishiiruka";
    description = "Play Melee online !";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Only;
  };
}
