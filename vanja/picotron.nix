# Picotron (https://www.lexaloffle.com/picotron.php), packaged from the
# purchased Linux zip. It is a paid download, so the zip is not fetched: add it
# to the Nix store on the machine that builds the config (see `message`).
{
  lib,
  stdenv,
  requireFile,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  SDL2,
  libGL,
  curl,
}:

stdenv.mkDerivation rec {
  pname = "picotron";
  version = "0.3.0d2";

  src = requireFile {
    name = "picotron_${version}_amd64.zip";
    url = "https://www.lexaloffle.com/picotron.php";
    hash = "sha256-deGRvkJJoItL7oLT0OAhJ67dMePZPQT+MLVTbY/PCEY=";
    message = ''
      Picotron is a paid download and must be added to the Nix store manually.
      Download picotron_${version}_amd64.zip from your Lexaloffle account, then run:

        nix-store --add-fixed sha256 picotron_${version}_amd64.zip

      and put the output of `nix hash file picotron_${version}_amd64.zip` into
      `hash` in nixos/picotron.nix.
    '';
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    SDL2
    libGL
    stdenv.cc.cc.lib
  ];

  # Loaded at runtime for BBS / remote cart downloads.
  runtimeDependencies = [ curl.out ];

  # picotron_dyn links against nixpkgs' SDL2. The static `picotron` bundles its
  # own SDL, which can't find X11 here and falls back to KMSDRM; under cage that
  # fails ("could not create renderer") and leaves tty1 unusable for the menu.
  # SDL_VIDEODRIVER=x11 runs it through cage's Xwayland, like Minecraft.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/picotron
    cp -r . $out/lib/picotron
    # The binary expects picotron.dat in the working directory.
    makeWrapper $out/lib/picotron/picotron_dyn $out/bin/picotron \
      --chdir $out/lib/picotron \
      --set-default SDL_VIDEODRIVER x11 \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}

    runHook postInstall
  '';

  meta = {
    description = "Fantasy workstation by Lexaloffle";
    homepage = "https://www.lexaloffle.com/picotron.php";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "picotron";
  };
}
