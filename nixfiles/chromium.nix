{ config, lib, pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    ];
    extraOpts = let
      # explicitly whitelist things that are allowed images/popups/javascript/etc
      # the immediate workaround is to use Firefox, otherwise just add entries here
      whitelist = [
        "[*.]localhost"
        "[*.]localdomain"

        "[*.]allegheny.edu"
        "[*.]amazon.com"
        "[*.]citizensbank.com"
        "[*.]citizensbankonline.com"
        "[*.]docker.com"
        "[*.]duckduckgo.com"
        "[*.]elixir-lang.org"
        "[*.]elixirforum.com"
        "[*.]elixirschool.com"
        "[*.]github.com"
        "[*.]github.io"
        "[*.]githubusercontent.com"
        "[*.]google.com"
        "[*.]hex.pm"
        "[*.]hexdocs.pm"
        "[*.]lenovo.com"
        "[*.]lobste.rs"
        "[*.]newegg.com"
        "[*.]nixos.org"
        "[*.]nixos.wiki"
        "[*.]oracle.com"
        "[*.]paypal.com"
        "[*.]pragprog.com"
        "[*.]reddit.com"
        "[*.]twitter.com"
        "[*.]wikipedia.org"
        "[*.]ycombinator.com"
      ];
    in {
      # https://cloud.google.com/docs/chrome-enterprise/policies

      # strictly whitelist sites above
      "DefaultImagesSetting" = 2; # disallow
      "DefaultJavaScriptSetting" = 2; # disallow
      "DefaultNotificationsSetting" = 2; # disallow
      "DefaultInsecureContentSetting" = 2; # disallow
      "DefaultPopupsSetting" = 2; # disallow
      "DefaultPluginsSetting" = 2; # disallow
      "DefaultCookiesSetting" = 4; # keep for session duration
      "JavaScriptAllowedForUrls" = whitelist;
      "ImagesAllowedForUrls" = whitelist;
      "InsecureContentAllowedForUrls" = whitelist;
      "PopupsAllowedForUrls" = whitelist;
      "AutoplayWhitelist" = whitelist;
      "AutoplayAllowed" = false;

      # serve my own homepage/newtab
      # FIXME: intention is to bind internal webapps to these, eventually.
      "ShowHomeButton" = true;
      "HomepageIsNewTabPage" = false;
      "HomepageLocation" = "https://lenovo.localdomain/homepage";
      "NewTabPageLocation" = "https://lenovo.localdomain/newtabpage";
      "RestoreOnStartup" = 5; # newtabpage

      # FIXME: revisit after looking into pfSense support.
      "DnsOverHttpsMode" = "off";

      # disable all manner of account-related things.
      "BrowserSignin" = 0; # disable
      "BrowserAddPersonEnabled" = false;
      "BrowserGuestModeEnabled" = false;
      "UserDisplayName" = "PolicyUser";
      "UserFeedbackAllowed" = false;
      "BackgroundModeEnabled" = false;
      "MetricsReportingEnabled" = false;
      "BlockExternalExtensions" = true;
      "AutofillAddressEnabled" = false;
      "AutofillCreditCardEnabled" = false;
      "PasswordManagerEnabled" = false;
      "PromptForDownloadLocation" = true;

      # usually it's just me testing things so allow it.
      "SSLErrorOverrideAllowed" = true;

      # prefer not-google for most search
      "DefaultSearchProviderEnabled" = true;
      "DefaultSearchProviderName" = "DuckDuckGoPolicy";
      "DefaultSearchProviderKeyword" = "duckduckgo.com";
      "DefaultSearchProviderIconURL" = "https://duckduckgo.com/favicon.ico";
      "DefaultSearchProviderSearchURL" = "https://duckduckgo.com?q={searchTerms}";

      # bookmarks management
      # when needing to browse through, use Ctrl+Shift+O.
      # otherwise, these are here for auto-complete purposes.
      "BookmarkBarEnabled" = false;
      "ShowAppsShortcutInBookmarkBar" = false;
      "ManagedBookmarks" = [
        { "toplevel_name" = "Managed Bookmarks"; }
        { "name" = "Network"; "children" = [
          { "url" = "https://netgate.localdomain"; name = "netgate"; }
          { "url" = "https://unifi.localdomain"; name = "unifi"; }
        ]; }
        { "name" = "Services"; "children" = [
          { "url" = "https://github.com/"; name = "github"; }
          { "url" = "https://digitalocean.com/"; name = "digitalocean"; }
          { "url" = "https://namecheap.com/"; name = "namecheap"; }
          { "url" = "https://linkedin.com/"; name = "linkedin"; }
          { "url" = "https://twitter.com/"; name = "twitter"; }
          { "url" = "https://amazon.com/"; name = "amazon"; }
          { "url" = "https://newegg.com/"; name = "newegg"; }
        ]; }
        { "name" = "Nix"; "children" = [
          { "url" = "https://nixos.org/nix/manual/"; name = "nix-manual"; }
          { "url" = "https://nixos.org/nixpkgs/manual/"; name = "nixpkgs-manual"; }
          { "url" = "https://nixos.org/nixos/manual/"; name = "nixos-manual"; }
          { "url" = "https://nixos.org/nixos/options.html"; name = "nixos-options"; }
          { "url" = "https://discourse.nixos.org/"; name = "nixos-discourse"; }
          { "url" = "https://old.reddit.com/r/nixos/"; name = "nixos-reddit"; }
          { "url" = "https://nixos.wiki/"; name = "nixos-wiki"; }
        ]; }
        { "name" = "Elixir"; "children" = [
          { "url" = "https://elixir-lang.org/"; name = "elixir-lang"; }
          { "url" = "https://elixir-lang.org/blog"; name = "elixir-blog"; }
          { "url" = "https://elixirforum.com/"; name = "elixir-forum"; }
          { "url" = "https://old.reddit.com/r/elixir/"; name = "elixir-reddit"; }
          { "url" = "https://elixir-lang.org/getting-started/introduction.html"; name = "elixir-book"; }
          { "url" = "https://elixirschool.com/en/"; name = "elixir-school"; }
          { "url" = "http://media.pragprog.com/titles/elixir/ElixirCheat.pdf"; name = "elixir-cheatsheet"; }
          { "url" = "https://hex.pm"; name = "elixir-hex"; }
          { "url" = "https://github.com/h4cc/awesome-elixir"; name = "elixir-awesome"; }
          { "url" = "https://hexdocs.pm/elixir/Kernel.html"; name = "elixir-docs-std"; }
          { "url" = "https://hexdocs.pm/elixir/Regex.html"; name = "elixir-docs-std-regex"; }
          { "url" = "https://hexdocs.pm/elixir/String.html"; name = "elixir-docs-std-string"; }
          { "url" = "https://hexdocs.pm/elixir/Enum.html"; name = "elixir-docs-std-enum"; }
          { "url" = "https://hexdocs.pm/elixir/List.html"; name = "elixir-docs-std-list"; }
          { "url" = "https://hexdocs.pm/elixir/Map.html"; name = "elixir-docs-std-map"; }
          { "url" = "https://hexdocs.pm/elixir/Supervisor.html"; name = "elixir-docs-std-supervisor"; }
          { "url" = "https://hexdocs.pm/elixir/GenServer.html"; name = "elixir-docs-std-genserver"; }
          { "url" = "https://hexdocs.pm/elixir/Process.html"; name = "elixir-docs-std-process"; }
          { "url" = "https://hexdocs.pm/eex/EEx.html"; name = "elixir-docs-eex"; }
          { "url" = "https://hexdocs.pm/ex_unit/ExUnit.html"; name = "elixir-docs-exunit"; }
          { "url" = "https://hexdocs.pm/iex/IEx.html"; name = "elixir-docs-iex"; }
          { "url" = "https://hexdocs.pm/logger/Logger.html"; name = "elixir-docs-logger"; }
          { "url" = "https://hexdocs.pm/mix/Mix.html"; name = "elixir-docs-mix"; }
        ]; }
        { "name" = "ZFS"; "children" = [
          { "url" = "https://www.freebsd.org/doc/handbook/zfs.html"; name = "zfs-handbook"; }
          { "url" = "https://wiki.archlinux.org/index.php/ZFS"; name = "zfs-archwiki"; }
          { "url" = "https://nixos.wiki/wiki/NixOS_on_ZFS"; name = "zfs-nixoswiki"; }
          { "url" = "https://wiki.gentoo.org/wiki/ZFS"; name = "zfs-gentoowiki"; }
          { "url" = "https://docs.oracle.com/cd/E26505_01/html/E37384/"; name = "zfs-oracle"; }
          { "url" = "https://old.reddit.com/r/zfs/"; name = "zfs-reddit"; }
        ]; }
      ];

    };
  };
}
