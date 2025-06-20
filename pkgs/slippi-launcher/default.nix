{
  electron,
  fetchFromGitHub,
  lib,
  makeDesktopItem,
  makeWrapper,
  mkYarnPackage,
  slippi-netplay,
  replaceVars,
}:

let
  pname = "slippi-launcher";
  version = "2.11.10";
  src = fetchFromGitHub {
    owner = "project-slippi";
    repo = "slippi-launcher";
    tag = "v${version}";
    hash = "sha256-JrM2nm5iEAoyrGeqF1iP+kKjdiC/3mfCihzawg3Xv9s=";
  };
in
mkYarnPackage {
  inherit pname version src;
  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";
  nativeBuildInputs = [
    makeWrapper
  ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  patches = [
    (replaceVars ./0001-replace-findDolphinExecutable-by-NIX_DOLPHIN_PATH-va.patch {
      NIX_DOLPHIN_PATH = "${lib.getExe slippi-netplay}";
    })
  ];

  postBuild = ''
    yarn --offline run package
      --dir \
      -c.electronDist=${electron}/lib/electron \
      -c.electronVersion=${electron.version}
  '';
  installPhase = ''
    runHook preInstall

    makeWrapper "${lib.getExe electron}" "$out/bin/${pname}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "Slippi Launcher";
      exec = "slippi-launcher %U";
      icon = "slippi-launcher";
      keywords = [
        "melee"
        "netplay"
        "rollback"
        "smash"
      ];
      categories = [
        "Emulator"
        "Game"
        "Network"
      ];
      terminal = false;
    })
  ];

  meta = {
    homepage = "https://slippi.gg";
    description = "The way to play Slippi Online and watch replays";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
  };
}
