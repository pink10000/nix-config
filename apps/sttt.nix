{ pkgs, ... }:

let
  sttt = pkgs.stdenv.mkDerivation {
    pname = "sttt";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/flick0/sttt/main/sttt";
      sha256 = "0v9377hg4a76wp9mn4bx7fs8hc27sn2a3qb1x7q15h6h1b9iivxg"; 
    };
    
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      install -m755 $src $out/bin/sttt
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    sttt
  ];
}

