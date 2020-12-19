{ config, lib, pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # Just Black theme
    ];
    extraOpts = let
      # explicitly whitelist things that are allowed images/popups/javascript/etc
      # the immediate workaround is to use Firefox, otherwise just add entries here
      whitelist = [
        "[*.]localhost"
        "[*.]localdomain"
        "file:///*"

        "[*.]nixos.org"
        "[*.]nixos.wiki"
        "[*.]github.com"
        "[*.]wikipedia.org"
      ];
    in {
      # https://cloud.google.com/docs/chrome-enterprise/policies

      # strictly whitelist sites above
      "DefaultNotificationsSetting" = 2; # disallow
      "DefaultPluginsSetting" = 2; # disallow
      "DefaultCookiesSetting" = 4; # keep for session duration

      # "DefaultImagesSetting" = 2; # disallow
      # "ImagesAllowedForUrls" = whitelist;

      # "DefaultJavaScriptSetting" = 2; # disallow
      # "JavaScriptAllowedForUrls" = whitelist;

      # "DefaultInsecureContentSetting" = 2; # disallow
      # "InsecureContentAllowedForUrls" = whitelist;

      # "DefaultPopupsSetting" = 2; # disallow
      # "PopupsAllowedForUrls" = whitelist;

      # "AutoplayAllowed" = false;
      # "AutoplayWhitelist" = whitelist;

      # serve my own homepage/newtab
      # FIXME: intention is to bind internal webapps to these, eventually.
      ShowHomeButton = false;
      HomepageIsNewTabPage = false;
      HomepageLocation = "chrome://version";
      NewTabPageLocation = "chrome://version";
      RestoreOnStartup = 5; # newtabpage

      # FIXME: revisit after looking into pfSense support.
      DnsOverHttpsMode = "off";

      # disable all manner of account-related things.
      BrowserSignin = 0; # disable
      BrowserAddPersonEnabled = false;
      BrowserGuestModeEnabled = false;
      UserDisplayName = "PolicyUser";
      UserFeedbackAllowed = false;
      BackgroundModeEnabled = false;
      MetricsReportingEnabled = false;
      BlockExternalExtensions = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      PasswordManagerEnabled = false;
      PromptForDownloadLocation = true;

      # usually it's just me testing things so allow it.
      SSLErrorOverrideAllowed = true;

      # prefer not-google for most search
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "DuckDuckGoPolicy";
      DefaultSearchProviderKeyword = "duckduckgo.com";
      DefaultSearchProviderIconURL = "https://duckduckgo.com/favicon.ico";
      DefaultSearchProviderSearchURL = "https://duckduckgo.com?q={searchTerms}";

      # bookmarks management
      # when needing to browse through, use Ctrl+Shift+O.
      # otherwise, these are here for auto-complete purposes.
      BookmarkBarEnabled = false;
      ShowAppsShortcutInBookmarkBar = false;
      ManagedBookmarks = [
        { toplevel_name = "Managed Bookmarks"; }
        { name = "Services::Internal"; children = [
          { name = "netgate"; url = "https://netgate.localdomain"; }
          { name = "pfsense"; url = "https://netgate.localdomain"; }
          { name = "unifi"; url = "https://unifi.localdomain"; }
        ]; }
        { name = "Services::External"; children = [
          { name = "amazon"; url = "https://amazon.com/"; }
          { name = "digitalocean"; url = "https://digitalocean.com/"; }
          { name = "github"; url = "https://github.com/"; }
          { name = "linkedin"; url = "https://linkedin.com/"; }
          { name = "namecheap"; url = "https://namecheap.com/"; }
          { name = "newegg"; url = "https://newegg.com/"; }
          { name = "twitter"; url = "https://twitter.com/"; }
          { name = "gmail"; url = "https://mail.google.com/mail/u/0/#inbox"; }
          { name = "gsuite"; url = "https://admin.google.com/?hl=en"; }
        ]; }
        { name = "Reference"; children = [
          { name = "carbon"; url = "https://www.carbondesignsystem.com/"; }
          { name = "carbon-icons"; url = "https://www.carbondesignsystem.com/guidelines/icons/library"; }
          { name = "crystal-book"; url = "https://crystal-lang.org/reference/getting_started/"; }
          { name = "crystal-docs"; url = "https://crystal-lang.org/docs/"; }
          { name = "crystal-forum"; url = "https://forum.crystal-lang.org/"; }
          { name = "crystal-lang"; url = "https://crystal-lang.org/"; }
          { name = "crystal-playground"; url = "https://play.crystal-lang.org/#/cr"; }
          { name = "elixir-awesome"; url = "https://github.com/h4cc/awesome-elixir"; }
          { name = "elixir-blog"; url = "https://elixir-lang.org/blog"; }
          { name = "elixir-book"; url = "https://elixir-lang.org/getting-started/introduction.html"; }
          { name = "elixir-cheatsheet"; url = "http://media.pragprog.com/titles/elixir/ElixirCheat.pdf"; }
          { name = "elixir-docs-eex"; url = "https://hexdocs.pm/eex/EEx.html"; }
          { name = "elixir-docs-exunit"; url = "https://hexdocs.pm/ex_unit/ExUnit.html"; }
          { name = "elixir-docs-iex"; url = "https://hexdocs.pm/iex/IEx.html"; }
          { name = "elixir-docs-logger"; url = "https://hexdocs.pm/logger/Logger.html"; }
          { name = "elixir-docs-mix"; url = "https://hexdocs.pm/mix/Mix.html"; }
          { name = "elixir-docs-std"; url = "https://hexdocs.pm/elixir/Kernel.html"; }
          { name = "elixir-docs-std-enum"; url = "https://hexdocs.pm/elixir/Enum.html"; }
          { name = "elixir-docs-std-genserver"; url = "https://hexdocs.pm/elixir/GenServer.html"; }
          { name = "elixir-docs-std-list"; url = "https://hexdocs.pm/elixir/List.html"; }
          { name = "elixir-docs-std-map"; url = "https://hexdocs.pm/elixir/Map.html"; }
          { name = "elixir-docs-std-process"; url = "https://hexdocs.pm/elixir/Process.html"; }
          { name = "elixir-docs-std-regex"; url = "https://hexdocs.pm/elixir/Regex.html"; }
          { name = "elixir-docs-std-string"; url = "https://hexdocs.pm/elixir/String.html"; }
          { name = "elixir-docs-std-supervisor"; url = "https://hexdocs.pm/elixir/Supervisor.html"; }
          { name = "elixir-forum"; url = "https://elixirforum.com/"; }
          { name = "elixir-hex"; url = "https://hex.pm"; }
          { name = "elixir-lang"; url = "https://elixir-lang.org/"; }
          { name = "elixir-reddit"; url = "https://old.reddit.com/r/elixir/"; }
          { name = "elixir-school"; url = "https://elixirschool.com/en/"; }
          { name = "go-awesome"; url = "https://github.com/avelino/awesome-go"; }
          { name = "go-by-example"; url = "https://gobyexample.com/"; }
          { name = "go-docs"; url = "https://golang.org/doc/"; }
          { name = "go-lang"; url = "https://golang.org/"; }
          { name = "go-pkgs"; url = "https://golang.org/pkg/"; }
          { name = "go-playground"; url = "https://play.golang.org/"; }
          { name = "go-reddit"; url = "https://www.reddit.com/r/golang"; }
          { name = "haskell-docs"; url = "https://www.haskell.org/documentation/"; }
          { name = "haskell-hackage"; url = "http://hackage.haskell.org/"; }
          { name = "haskell-hoogle"; url = "https://hoogle.haskell.org/"; }
          { name = "haskell-lang"; url = "https://www.haskell.org/"; }
          { name = "haskell-stackage"; url = "https://www.stackage.org/"; }
          { name = "nim-curated"; url = "https://github.com/nim-lang/Nim/wiki/Curated-Packages"; }
          { name = "nim-lang"; url = "https://nim-lang.org/"; }
          { name = "nim-manual"; url = "https://nim-lang.org/docs/manual.html"; }
          { name = "nim-nimble"; url = "https://nimble.directory/"; }
          { name = "nim-playground"; url = "https://play.nim-lang.org/"; }
          { name = "nim-reddit"; url = "http://reddit.com/r/nim"; }
          { name = "nim-std"; url = "https://nim-lang.org/docs/lib.html"; }
          { name = "nim-tutorial-p1"; url = "https://nim-lang.org/docs/tut1.html"; }
          { name = "nim-tutorial-p2"; url = "https://nim-lang.org/docs/tut2.html"; }
          { name = "nim-tutorial-p3"; url = "https://nim-lang.org/docs/tut3.html"; }
          { name = "nix-manual"; url = "https://nixos.org/nix/manual/"; }
          { name = "nixos-discourse"; url = "https://discourse.nixos.org/"; }
          { name = "nixos-manual"; url = "https://nixos.org/nixos/manual/"; }
          { name = "nixos-options"; url = "https://nixos.org/nixos/options.html"; }
          { name = "nixos-reddit"; url = "https://old.reddit.com/r/nixos/"; }
          { name = "nixos-wiki"; url = "https://nixos.wiki/"; }
          { name = "nixpkgs-manual"; url = "https://nixos.org/nixpkgs/manual/"; }
          { name = "nodejs-api"; url = "https://nodejs.org/api/"; }
          { name = "nodejs-docs"; url = "https://nodejs.org/en/docs/"; }
          { name = "ocaml-docs"; url = "https://ocaml.org/docs/"; }
          { name = "ocaml-lang"; url = "https://ocaml.org/"; }
          { name = "ocaml-opam"; url = "https://opam.ocaml.org/"; }
          { name = "python-docs"; url = "https://docs.python.org/3/"; }
          { name = "python-lang"; url = "https://www.python.org/"; }
          { name = "python-pypi"; url = "https://pypi.org/"; }
          { name = "ruby-awesome"; url = "https://github.com/markets/awesome-ruby"; }
          { name = "ruby-docs"; url = "https://www.ruby-lang.org/en/documentation/"; }
          { name = "ruby-gems"; url = "https://rubygems.org/"; }
          { name = "ruby-lang"; url = "https://www.ruby-lang.org/en/"; }
          { name = "ruby-reddit"; url = "https://www.reddit.com/r/ruby"; }
          { name = "rust-awesome"; url = "https://github.com/rust-unofficial/awesome-rust"; }
          { name = "rust-book"; url = "https://doc.rust-lang.org/book/"; }
          { name = "rust-by-example"; url = "https://doc.rust-lang.org/stable/rust-by-example/"; }
          { name = "rust-cargo-book"; url = "https://doc.rust-lang.org/cargo/index.html"; }
          { name = "rust-lang"; url = "https://www.rust-lang.org/"; }
          { name = "rust-playground"; url = "https://play.rust-lang.org/"; }
          { name = "rust-reddit"; url = "https://www.reddit.com/r/rust/"; }
          { name = "rust-rustc-book"; url = "https://doc.rust-lang.org/rustc/index.html"; }
          { name = "rust-rustdoc-book"; url = "https://doc.rust-lang.org/rustdoc/index.html"; }
          { name = "rust-std"; url = "https://doc.rust-lang.org/std/index.html"; }
          { name = "scala-dex"; url = "https://index.scala-lang.org/"; }
          { name = "scala-docs"; url = "https://docs.scala-lang.org/"; }
          { name = "scala-lang"; url = "https://scala-lang.org/"; }
          { name = "scala-reddit"; url = "https://reddit.com/r/scala"; }
          { name = "scala-std"; url = "https://www.scala-lang.org/api/current/"; }
          { name = "svelte"; url = "https://svelte.dev/"; }
          { name = "svelte-carbon-docs"; url = "https://carbon-svelte.vercel.app/"; }
          { name = "svelte-carbon-src"; url = "https://github.com/IBM/carbon-components-svelte"; }
          { name = "svelte-docs"; url = "https://svelte.dev/docs"; }
          { name = "svelte-examples"; url = "https://svelte.dev/examples"; }
          { name = "svelte-spa-router"; url = "https://github.com/ItalyPaleAle/svelte-spa-router"; }
          { name = "zfs-archwiki"; url = "https://wiki.archlinux.org/index.php/ZFS"; }
          { name = "zfs-gentoowiki"; url = "https://wiki.gentoo.org/wiki/ZFS"; }
          { name = "zfs-handbook"; url = "https://www.freebsd.org/doc/handbook/zfs.html"; }
          { name = "zfs-nixoswiki"; url = "https://nixos.wiki/wiki/NixOS_on_ZFS"; }
          { name = "zfs-oracle"; url = "https://docs.oracle.com/cd/E26505_01/html/E37384/"; }
          { name = "zfs-reddit"; url = "https://old.reddit.com/r/zfs/"; }
          { name = "zig-awesome"; url = "https://github.com/nrdmn/awesome-zig"; }
          { name = "zig-docs"; url = "https://ziglang.org/documentation/0.6.0/"; }
          { name = "zig-docs-std"; url = "https://ziglang.org/documentation/0.6.0/std/"; }
          { name = "zig-github"; url = "https://github.com/ziglang/zig"; }
          { name = "zig-issues"; url = "https://github.com/ziglang/zig/issues"; }
          { name = "zig-lang"; url = "https://ziglang.org"; }
          { name = "zig-learn"; url = "https://ziglearn.org"; }
          { name = "zig-reddit"; url = "https://old.reddit.com/r/Zig/"; }
          { name = "zig-releases"; url = "https://ziglang.org/download/"; }
        ]; }
      ];

    };
  };
}
