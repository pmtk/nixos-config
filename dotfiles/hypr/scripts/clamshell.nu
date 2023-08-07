#!/usr/bin/env nu

# Thanks: https://bobbys.zone/guides/hyprland-clamshell

def main [operation: string] {
    let monitors = (hyprctl monitors -j | from json)
    let external = $monitors | filter {|m| ($m.name | str starts-with "DP-")}

    if not ($external | is-empty) {
        if $operation == "open" {
            hyprctl keyword monitor "eDP-1, 1920x1080,     3440x1200, 1"
	} else {
            hyprctl keyword monitor "eDP-1, disable"
	}
    }
}
