{
  fetchFromGitHub,
  fetchYarnDeps,
  lib,
  git,
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
    hash = "sha256-ArFRjTMObYzHtGWrexYDyLdke1NBiyHjdpp/QXMQKxM=";
    postFetch = ''
      cd $out
      patch < ${./0001-make-yarn.lock-fetch-from-yarn-registry-for-node-gyp.patch}
    '';
    # Needed for some fuckass `git rev-parse` that I don't wanna patch
    leaveDotGit = true;
  };

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  patches = [
    (replaceVars ./0001-replace-findDolphinExecutable-by-NIX_DOLPHIN_PATH-va.patch {
      NIX_DOLPHIN_PATH = "${lib.getExe slippi-netplay}";
    })
  ];

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-MgYpnTyDG5ih6yIiVMjejJuLHy5Q2+/tvPUUEaON9xg=";
  };

  nativeBuildInputs = [
    git
    makeWrapper
    nodejs
    yarnBuildHook
    yarnConfigHook
  ];
  installPhase = ''
    runHook preInstall
    echo "Running install phase"

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
