{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  pipewire,
  libpulseaudio,
}:

stdenv.mkDerivation {
  pname = "soloist";
  version = "1.3.8.103";

  src = fetchurl {
    url = "https://soloist-builds.spotifycdn.com/soloist_release_x86_64.tar.gz";
    hash = "sha256-v775IrORDgPMMSCgWjYMmXw/sntF3+zxETr/rfkHhko=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  runtimeDependencies = [
    pipewire
    libpulseaudio
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 soloist "$out/bin/soloist"
    install -Dm644 CHANGELOG.md "$out/share/doc/soloist/CHANGELOG.md"
    install -Dm644 THIRD_PARTY_LICENSES.txt "$out/share/doc/soloist/THIRD_PARTY_LICENSES.txt"
    runHook postInstall
  '';

  meta = {
    description = "Spotify Connect player for Linux";
    homepage = "https://developer.spotify.com/documentation/soloist/tutorials/getting-started";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "soloist";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
