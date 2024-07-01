#!/usr/bin/env bash
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT_DIR/../utils.sh"


# echo "#{battery_percentage} #{battery_icon}"
battery_percentage=$(pmset -g batt | grep -o "[0-9]\{1,3\}%")
charging_status=$(pmset -g batt | awk -F '; *' 'NR==2 { print $2 }')

if [ "$charging_status" ==  "charging" ]; then
    plugin_battery_icon=" "
else
    plugin_battery_icon="󰁹 "
fi

battery_number="${battery_percentage//%/}"

if [ "$battery_number" -gt 30 ]; then
    plugin_battery_accent_color=$(get_tmux_option "@theme_plugin_weather_accent_color" "blue7")
    plugin_battery_accent_color_icon=$(get_tmux_option "@theme_plugin_weather_accent_color_icon" "blue0")
elif [ "$battery_number" -gt 10 ]; then
    plugin_battery_accent_color=$(get_tmux_option "@theme_plugin_weather_accent_color" "yellow")
    plugin_battery_accent_color_icon=$(get_tmux_option "@theme_plugin_weather_accent_color_icon" "yellow2")
else
    plugin_battery_accent_color=$(get_tmux_option "@theme_plugin_weather_accent_color" "red")
    plugin_battery_accent_color_icon=$(get_tmux_option "@theme_plugin_weather_accent_color_icon" "red1")
fi

export plugin_battery_icon plugin_battery_accent_color plugin_battery_accent_color_icon

echo $battery_percentage
