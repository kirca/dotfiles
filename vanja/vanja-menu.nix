# Kiosk-style TUI menu for Vanja.
#
# Vanja is auto-logged-in on tty1 and the login shell *is* the menu, so there
# is no way to reach a regular shell. Each selected program runs fullscreen in
# the `sway` Wayland compositor with a kiosk config (no bar, no keybindings);
# when it exits, sway exits and the menu comes back. (sway rather than cage
# because cage ignores drawing tablets.)
# If the menu itself ever exits, the session ends and getty logs Vanja in again.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vanjaMenu;

  appNames = lib.attrNames cfg.apps;

  menuItems = lib.concatMapStringsSep " " (
    name: "${lib.escapeShellArg name} ${lib.escapeShellArg cfg.apps.${name}.label}"
  ) appNames;

  # Runs the app, then ends the sway session. A script because sway's `exec`
  # treats `;` as a command separator.
  launcher =
    name:
    pkgs.writeShellScript "vanja-${name}" ''
      ${cfg.apps.${name}.command}
      ${pkgs.sway}/bin/swaymsg exit
    '';

  # -c skips sway's default config, so there are no keybindings or bar. A single
  # borderless tiled window fills the screen without being marked fullscreen;
  # forcing fullscreen on SDL/X11 apps (Picotron) offsets their mouse.
  swayConfig =
    name:
    pkgs.writeText "vanja-sway-${name}.conf" ''
      default_border none
      default_floating_border none
      focus_follows_mouse no
      swaynag_command -
      xwayland enable
      ${cfg.apps.${name}.extraSwayConfig}
      exec ${launcher name}
    '';

  caseArms = lib.concatMapStringsSep "\n" (name: ''
    ${lib.escapeShellArg name}) sway -c ${swayConfig name} >>"$log" 2>&1 || true ;;
  '') appNames;

  menu = pkgs.writeShellApplication {
    name = "vanja-menu";
    runtimeInputs = with pkgs; [
      sway
      dialog
      ncurses
      systemd
    ];
    text = ''
      # Keep Ctrl+C / Ctrl+\ / Ctrl+Z from killing the menu. A handler (rather
      # than ignoring the signal) lets launched programs get default behaviour.
      trap ':' INT QUIT TSTP

      log="$HOME/.cache/vanja-menu.log"
      mkdir -p "$(dirname "$log")"

      while true; do
        choice=$(dialog --stdout --no-cancel \
          --backtitle ${lib.escapeShellArg cfg.backtitle} \
          --title ${lib.escapeShellArg cfg.title} \
          --menu "Choose a program:" 0 0 0 \
          ${menuItems} \
          restart "Restart computer" \
          shutdown "Shut down computer") || { sleep 1; continue; }
        clear
        case "$choice" in
          ${caseArms}
          restart) systemctl reboot ;;
          shutdown) systemctl poweroff ;;
        esac
      done
    '';
    # Lets NixOS use the package directly as a login shell.
    passthru.shellPath = "/bin/vanja-menu";
  };
in
{
  options.vanjaMenu = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "vanja";
      description = "User that is auto-logged-in on tty1 into the menu.";
    };

    title = lib.mkOption {
      type = lib.types.str;
      default = "Hi Vanja!";
      description = "Title of the menu window.";
    };

    backtitle = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";
      description = "Text shown in the top-left corner of the screen.";
    };

    apps = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            label = lib.mkOption {
              type = lib.types.str;
              description = "Name shown in the menu.";
            };
            command = lib.mkOption {
              type = lib.types.str;
              description = "Command (with arguments) started inside sway.";
            };
            extraSwayConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra sway config lines for this app's session.";
            };
          };
        }
      );
      default = { };
      description = "Programs offered in the menu, sorted by attribute name.";
    };
  };

  config = {
    users.users.${cfg.user}.shell = menu;
    environment.shells = [ menu ];

    # Auto-login on tty1 only; the other VTs keep a normal login prompt so the
    # admin can switch with Ctrl+Alt+F2. (services.getty.autologinUser would
    # apply to every VT.)
    systemd.services."getty@tty1" = {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "${lib.getExe' pkgs.util-linux "agetty"} --login-program ${config.services.getty.loginProgram} --autologin ${cfg.user} --noclear --keep-baud %I 115200,38400,9600 $TERM"
      ];
    };

    # Games using GLFW/SDL on X11 (e.g. Minecraft) run through Xwayland in sway.
    programs.xwayland.enable = true;
    fonts.packages = [ pkgs.dejavu_fonts ];
  };
}
