{ lib, stdenv, fetchurl, pkgconfig, pruneLibtoolFiles, flex, bison
, libmnl, libnetfilter_conntrack, libnfnetlink, libnftnl, libpcap
, nftablesCompat ? false
}:

with lib;

stdenv.mkDerivation rec {
  version = "1.8.6";
  pname = "iptables";

  src = fetchurl {
    url = "https://www.netfilter.org/projects/${pname}/files/${pname}-${version}.tar.bz2";
    sha256 = "0rvp0k8a72h2snrdx48cfn75bfa0ycrd2xl3kjysbymq7q6gxx50";
  };

  nativeBuildInputs = [ pkgconfig pruneLibtoolFiles flex bison ];

  buildInputs = [ libmnl libnetfilter_conntrack libnfnetlink libnftnl libpcap ];

  preConfigure = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -lmnl -lnftnl"
  '';

  configureFlags = [
    "--enable-bpf-compiler"
    "--enable-devel"
    "--enable-libipq"
    "--enable-nfsynproxy"
    "--enable-shared"
  ] ++ optional (!nftablesCompat) "--disable-nftables";

  outputs = [ "out" "dev" ];

  postInstall = optional nftablesCompat ''
    rm $out/sbin/{iptables,iptables-restore,iptables-save,ip6tables,ip6tables-restore,ip6tables-save}
    ln -sv xtables-nft-multi $out/bin/iptables
    ln -sv xtables-nft-multi $out/bin/iptables-restore
    ln -sv xtables-nft-multi $out/bin/iptables-save
    ln -sv xtables-nft-multi $out/bin/ip6tables
    ln -sv xtables-nft-multi $out/bin/ip6tables-restore
    ln -sv xtables-nft-multi $out/bin/ip6tables-save
  '';

  meta = {
    description = "A program to configure the Linux IP packet filtering ruleset";
    homepage = "https://www.netfilter.org/projects/iptables/index.html";
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ];
    license = licenses.gpl2;
    downloadPage = "https://www.netfilter.org/projects/iptables/files/";
    updateWalker = true;
    inherit version;
  };
}
