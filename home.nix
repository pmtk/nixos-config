{ config, pkgs, ... }:

{
  home.username = "pm";
  home.homeDirectory = "/home/pm";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Patryk Matuszak";
    userEmail = "pmtk@redhat.com";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    slack
    go
    #nushell
    libvirt

    brave
    bluetuith
    pavucontrol
    spotifywm

    lazygit
    fd
    ripgrep-all


    neofetch
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    exa # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    eww-wayland
  ];

  xdg.desktopEntries.spotifywm = {
    name = "Spotify WM";
    exec = "spotifywm";
    terminal = false;
    type = "Application";
  };

  # https://nixos.wiki/wiki/Visual_Studio_Code
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;

    extensions = with pkgs.vscode-extensions; [
      bodil.file-browser
      foxundermoon.shell-format
      golang.go
      ms-python.python
      ms-python.vscode-pylance
      redhat.vscode-yaml
      tamasfe.even-better-toml
      timonwong.shellcheck
      vscodevim.vim
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "robotcode";
        publisher = "d-biehl";
        version = "0.47.5";
        sha256 = "ad001e2f5a10f566804d98607fab9a10b114dcf97c674b6875f8b9cd3d0d91ba";
      }
      {
        name = "vscode-markdown-github";
        publisher = "lzm0x219";
        version = "3.1.0";
        sha256 = "9b932991a14e236841ad3beccf7e6105bde80f9be39bf7103bf5a6b528ae0f6c";
      }
      {
        name = "isort";
        publisher = "ms-python";
        version = "2023.11.12061012";
        sha256 = "19ada003b74e2b3a7c153a69edd4b50fc479836640254e7955a2a88a33aab276";
      }
      {
        name = "black-formatter";
        publisher = "ms-python";
        version = "2023.5.11951008";
        sha256 = "261e5f61aec8c29b8240dc718a198e2cefd6b336362f5ca94bd835150565f496";
      }
      {
        name = "text-power-tools";
        publisher = "qcz";
        version = "1.41.0";
        sha256 = "297b06b6ccb43a907e36572467cc876128c73f952401ed2c69bbddaaa93d2bd5";
      }
      {
        name = "code-spell-checker";
        publisher = "streetsidesoftware";
        version = "2.20.5";
        sha256 = "211fe6c049a248f37f65189acdc95148e89ef5102374d334cd77b15732263acf";
      }
      {
        name = "vscode-nushell-lang";
        publisher = "thenuprojectcontributors";
        version = "1.6.0";
        sha256 = "513af567d973d54ec80d8dc6b599321708548fb1696606ebdc6e1d23c03298a5";
      }
      {
        name = "vscode-status-bar-format-toggle";
        publisher = "tombonnike";
        version = "3.1.1";
        sha256 = "999ca61db749ec70fa69c04fa26c312b26ad0df9033c00343da6693d4fa75624";
      }
    ];
  };

  # starship - an customizable prompt for any shell
  # programs.starship = {
  #   enable = true;
  #   # custom settings
  #   settings = {
  #     add_newline = false;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #   };
  # };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  # programs.alacritty = {
  #   enable = true;
  #   # custom settings
  #   settings = {
  #     env.TERM = "xterm-256color";
  #     font = {
  #       size = 12;
  #       draw_bold_text_with_bright_colors = true;
  #     };
  #     scrolling.multiplier = 5;
  #     selection.save_to_clipboard = true;
  #   };
  # };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your cusotm bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./dotfiles/nushell/config.nu;
    envFile.source = ./dotfiles/nushell/env.nu;
  };

  # programs.eww = {
  #   enable = true;
  #   package = pkgs.eww-wayland;
  #   configDir = ./dotfiles/eww;
  # };

  home.file.".config/hypr" = {
    source = ./dotfiles/hypr;
    recursive = true;
  };
  home.file.".config/mako" = {
    source = ./dotfiles/mako;
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = ./dotfiles/waybar;
    recursive = true;
  };

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   settings = {
  #     "$mod" = "SUPER";
  #     bind = [
  #       "$mod, B, exec, firefox"
  #     ];
  #   };
  # };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
