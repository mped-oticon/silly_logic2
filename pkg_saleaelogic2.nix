with import <nixpkgs> {};

let
  name = "saleae-logic-2";
  version = "2.3.56";
  src = fetchurl {
    url = "https://downloads.saleae.com/logic2/Logic-${version}-master.AppImage";
    sha256 = "1327pbls6vxj8v22bx5zl6p4i4vjfpp3wk839zz9jfy6ik47czkl"; 
  };
in
appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands =
    let
      appimageContents = appimageTools.extractType2 { inherit name src; };
    in
      ''
        mkdir -p $out/etc/udev/rules.d
        cp ${appimageContents}/resources/linux/99-SaleaeLogic.rules $out/etc/udev/rules.d/
        ln -s "${appimageContents}" $out/wdh_extracted_appimage
      '';

  extraPkgs = pkgs: with pkgs; [
    wget
    unzip
    glib
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    nss
    nspr
    dbus
    gdk-pixbuf
    gtk3
    pango
    atk
    cairo
    expat
    xorg.libXrandr
    xorg.libXScrnSaver
    alsa-lib
    at-spi2-core
    cups
  ];

  meta = with lib; {
    homepage = "https://www.saleae.com/";
    description = "Software for Saleae logic analyzers";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ "mped@demant.com" ];
  };
}
