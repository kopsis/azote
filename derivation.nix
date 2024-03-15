{ lib
, fetchFromGitHub
, atk
, gdk-pixbuf
, gobject-introspection
, gtk-layer-shell
, gtk3
, pango
, python310Packages
, wrapGAppsHook
, hyprlandSupport ? true
}:

let
  fs = lib.fileset;
  sourceFiles =
    fs.difference
      ./.
      (fs.unions [
        (fs.maybeMissing ./result)
        (fs.fileFilter (file: file.hasExt "nix") ./.)
      ]);
in

python310Packages.buildPythonApplication rec {
  pname = "azote";
  version = "1.12.5";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  postPatch = ''
    substituteInPlace azote/tools.py --replace '/usr/share' $out/share
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    atk
    gdk-pixbuf
    gtk-layer-shell
    pango
    python310Packages.colorthief
    python310Packages.pillow
    python310Packages.pycairo
    python310Packages.pygobject3
    python310Packages.send2trash
  ] ++ lib.optionals hyprlandSupport [
  ];

  dontWrapGApps = true;

  postInstall = ''
    install -Dm444 dist/azote.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm444 dist/azote.desktop -t $out/share/applications
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}");
  '';

  # Upstream has no tests
  doCheck = false;

  meta = {
    homepage = "https://github.com/nwg-piotr/azote";
    description = "Wallpaper manager for sway and some other WMs";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ ];
    mainProgram = "azote";
  };
}
