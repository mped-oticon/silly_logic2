with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "jwm-run";
  version = "0.1.0";

  src = fetchFromGitHub {
    repo = "jwm-run";
    owner = "mped-oticon";
    rev = "v${version}";
    sha256 = "0cin55gk6pj7y1176x592f153pd85lzymdr5ybq6mrjjc4lvjq45";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
  '';

  meta = {
    description = "A bash-tool to run X applications under minimal Window Manager";
    homepage = "https://github.com/mped-oticon/jwm-run";
    license = lib.licenses.mit;
    maintainers = [ "Mark Ruvald Pedersen" ];
    platforms = lib.platforms.all;
  };
}
