{
  pkgs,
  lib,
  ...
}:

# The CAD tools product-design drives, on Linux (WSL and Ubuntu), from their own release files:
# - SolidCraft (its MCP server, `solidcraft-cli mcp`, is what agents design in; `solidcraft` the GUI);
# - FreeCAD 1.1's own Python as `freecad-python`, which product-design's engine runs on
#   (FREECAD_PYTHON). nixpkgs' FreeCAD isn't 1.1 everywhere, and the engine needs 1.1.
# Both are the vendors' binaries as built: they run on the system's loader and libraries (fine on
# Ubuntu, not NixOS). Headless, SolidCraft's pictures need SOLIDCRAFT_GPU=cpu (llvmpipe takes minutes).
# The MCP server is registered once, at user scope:
#   claude mcp add -s user solidcraft -e SOLIDCRAFT_GPU=cpu -- solidcraft-cli mcp
let
  solidcraft = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "solidcraft";
    version = "0.49.1";
    src = pkgs.fetchurl {
      url = "https://github.com/tangency-labs/solidcraft/releases/download/v${version}/solidcraft-${version}-linux-x86_64.tar.gz";
      sha256 = "1a99be684b5b86efa31b3c2671872b666b5e755dc18484bcb525600a0ff59daa";
    };
    sourceRoot = ".";
    dontPatchELF = true;
    dontStrip = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      root=$(dirname "$(find . -path '*/bin/solidcraft-cli' | head -n1)")/..
      mkdir -p $out
      cp -r "$root"/. $out/
      runHook postInstall
    '';
  };

  freecad = pkgs.appimageTools.extractType2 {
    pname = "freecad";
    version = "1.1.0";
    src = pkgs.fetchurl {
      url = "https://github.com/FreeCAD/FreeCAD/releases/download/1.1.0/FreeCAD_1.1.0-Linux-x86_64-py311.AppImage";
      sha256 = "ef85f171f2d09eec93f358bc49c1730d33f72bfbd353e6465609b30e45acf2f0";
    };
  };

  freecad-python = pkgs.writeShellScriptBin "freecad-python" ''
    # FreeCAD 1.1's own python (the Linux AppImage, extracted), with FreeCAD importable
    export PYTHONHOME=${freecad}/usr
    export PYTHONPATH=${freecad}/usr/lib''${PYTHONPATH:+:$PYTHONPATH}
    export LD_LIBRARY_PATH=${freecad}/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${freecad}/usr/bin/python "$@"
  '';
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [
      solidcraft
      freecad-python
    ];
    home.sessionVariables.FREECAD_PYTHON = "${freecad-python}/bin/freecad-python";
  };
}
