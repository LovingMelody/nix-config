{
  settings = {
    add_newline = false;
    battery = {
      full_symbol = "🔋";
      charging_symbol = "⚡️";
      discharging_symbol = "💀";
      display = [
        {
          threshold = 10;
          style = "bold red";
        }
        {
          threshold = 30;
          style = "bold yellow";
        }
      ];
    };
    directory = {
      substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
        "/mnt/c/Users/melody" = "~/";
        "/mnt/c" = "";
      };
    };
    username = {
      show_always = true;
    };
    time.disabled = false;
    format = "$all";
  };
}
