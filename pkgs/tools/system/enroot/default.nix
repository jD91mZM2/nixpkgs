{
  lib, stdenv, fetchFromGitHub, autoconf, automake, libtool, curl, gawk, jq,
  squashfsTools, parallel, makeWrapper,
}:

let
  runtimeDeps = [ curl gawk jq squashfsTools parallel ];
in stdenv.mkDerivation rec {
  pname = "enroot";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner  = "NVIDIA";
    repo   = pname;
    rev    = "v${version}";
    sha256 = "sha256-uJ2SpqUGZHngq47wa3hLFAg2QSfLInI6dtl/u66tnMo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoconf automake libtool makeWrapper ];
  buildInputs = [];

  buildPhase = ''
    make prefix="$out" all
  '';
  installPhase = ''
    make prefix="$out" install

    wrapProgram "$out/bin/enroot" --prefix PATH : "${lib.makeBinPath runtimeDeps}:$out/bin"
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/NVIDIA/enroot";
    description = "Supercharged chroot using Linux namespaces";
    license = licenses.asl20;
    maintainers = with maintainers; [ jD91mZM2 ];
    platforms = platforms.linux;
  };

}
