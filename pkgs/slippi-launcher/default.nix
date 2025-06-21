{
  electron,
  fetchFromGitHub,
  fetchYarnDeps,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs,
  replaceVars,
  slippi-netplay,
  stdenv,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slippi-launcher";
  version = "2.11.10";
  src = fetchFromGitHub {
    owner = "project-slippi";
    repo = "slippi-launcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JrM2nm5iEAoyrGeqF1iP+kKjdiC/3mfCihzawg3Xv9s=";
  };
  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-zrN8ZY6ZO/L4gDufWY1Ts00mauAaQxyQTbaqjKBt0kI=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    yarnBuildHook
    yarnConfigHook
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  patches = [
    (replaceVars ./0001-replace-findDolphinExecutable-by-NIX_DOLPHIN_PATH-va.patch {
      NIX_DOLPHIN_PATH = "${lib.getExe slippi-netplay}";
    })
  ];

  yarnBuildScript = "run package";
  yarnBuildFlags = [
    "--dir"
    "-c.electronDist=${electron.dist}"
    "-c.electronVersion=${electron.version}"
  ];
  installPhase = ''
    runHook preInstall

    makeWrapper "${lib.getExe electron}" "$out/bin/${finalAttrs.pname}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
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
    mainProgram = finalAttrs.pname;
    homepage = "https://slippi.gg";
    description = "The way to play Slippi Online and watch replays";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl3Only;
  };
})
