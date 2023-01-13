with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "expose-as-vnc-server";
  version = "0.1.1";

  src = fetchFromGitHub {
    repo = "expose-as-vnc-server";
    owner = "mped-oticon";
    rev = "v${version}";
    sha256 = "1j3g0wcnz341bj7m1ccga3ldi1gkxzcj061dfrkry7506bbg7g62";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
  '';

  meta = {
    description = "A bash-tool to expose X apps as VNC servers";
    homepage = "https://github.com/mped-oticon/expose-as-vnc-server";
    license = lib.licenses.mit;
    maintainers = [ "Mark Ruvald Pedersen" ];
    platforms = lib.platforms.all;
  };
}
