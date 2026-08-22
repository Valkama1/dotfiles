-- Desktop Monitor Setup (Gaming vs TV Toggle)
local monitor_state = "gaming"
local state_file = io.open(os.getenv("HOME") .. "/.config/hypr/monitor_state", "r")
if state_file then
    monitor_state = state_file:read("*a"):gsub("%s+", "")
    state_file:close()
end

if monitor_state == "tv" then
    hl.monitor({ output = "DP-2", disabled = true })
    hl.monitor({ output = "HDMI-A-2", disabled = true })
    hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "auto", scale = 1, disabled = false })
else
    hl.monitor({ output = "DP-2", mode = "2560x1440@240", position = "auto", scale = "auto", disabled = false })
    hl.monitor({ output = "HDMI-A-2", mode = "2560x1440@144", position = "0x-550", scale = 1, transform = 1, disabled = false })
    hl.monitor({ output = "HDMI-A-1", disabled = true })
end
