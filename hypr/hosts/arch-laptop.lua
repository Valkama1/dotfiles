-- Laptop Monitor Setup (arch-laptop)
-- Built-in display (Lenovo 2.8K 90Hz display)
hl.monitor({ output = "eDP-1", mode = "2880x1800@90", position = "auto", scale = 1.5, disabled = false })

-- Fallback for any connected external monitors on laptop
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
