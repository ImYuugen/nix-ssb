{
  appimageTools,
  makeDesktopItem,
  makeWrapper,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "slippi-launcher";
  version = "2.11.10";

  src = appimageTools.wrapType2 {
    inherit (finalAttrs) pname version;
    src = fetchurl {
      url = "https://github.com/project-slippi/slippi-launcher/releases/download/v${finalAttrs.version}/Slippi-Launcher-${finalAttrs.version}-x86_64.AppImage";
      hash = "sha256-OrWd0jVqe6CzNbVRNlm2alt2NZ8uBYeHiASaB74ouW4=";
    };
    nativeBuildInputs = [ makeWrapper ];
    extraInstallCommands = ''
      wrapProgram $out/bin/slippi-launcher \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    '';
  };

  desktopItems = [
    (makeDesktopItem {
      name = "slippi-launcher";
      exec = "slippi-launcher";
      icon = "slippi-launcher";
      desktopName = "Slippi Launcher";
      comment = "The way to play Slippi Online and watch replays";
      type = "Application";
      categories = [
        "Game"
      ];
      keywords = [
        "slippi"
        "melee"
        "rollback"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp -r "$src/bin" "$out"
    runHook postInstall
  '';
})
