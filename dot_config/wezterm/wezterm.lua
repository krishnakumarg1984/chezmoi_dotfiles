local status_ok, wezterm = pcall(require, "wezterm")
if not status_ok then
  return
end

return {
  -- harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  adjust_window_size_when_changing_font_size = false, -- https://github.com/wez/wezterm/issues/431
  font = wezterm.font_with_fallback({
    {
      family = "VictorMono Nerd Font",
      weight = "DemiBold",
      italic = false,
      harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
    },
    "CaskaydiaCove Nerd Font",
    "Cascadia Code PL",
    "Emoji One",
    "Material Design Icons Desktop",
    -- "Noto Color Emoji",
    "JetBrains Mono NL",
    "JetBrains Mono",
  }),
  font_size = 19,
  line_height = 1.0,
  use_dead_keys = false,
  color_scheme = "DoomOne",
  scrollback_lines = 10000, -- How many lines of scrollback you want to retain per tab
  enable_scroll_bar = true, -- Enable the scrollbar. It will occupy the right window padding space. If right padding is set to 0 then it will be increased to a single cell width
  hide_tab_bar_if_only_one_tab = true,
}
