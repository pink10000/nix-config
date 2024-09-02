{ pkgs, lib, ... }:

{
  xdg.portal.enable = true;

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "application/xhtml+xml" = "vivaldi-stable.desktop";
      "text/html" = "vivaldi-stable.desktop";
      "text/xml" = "vivaldi-stable.desktop";
      "x-scheme-handler/ftp" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
    };
  };

}

