with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "expose-as-vnc-server";
  version = "0.1.0";

  src = fetchFromGitHub {
    repo = "expose-as-vnc-server";
    owner = "mped-oticon";
    rev = "v${version}";
    sha256 = "16ji49szf2wn3h0dy847042v3mf31k7vx193252phr3x62sf1rzx";
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
