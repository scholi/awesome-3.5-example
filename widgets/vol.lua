local beautiful = require("beautiful")
local awful = require("awful")
local vicious = require("vicious")
local blingbling = require("blingbling")
local wibox = require("wibox")
local setmetatable = setmetatable

module("widgets.vol")

-- Volume widget
function new(terminal)
	local vol=setmetatable({},vol)
	vol.icon = wibox.widget.imagebox()
	vol.icon:set_image(beautiful.widget_vol)
	vol.icon:buttons (awful.util.table.join (
		awful.button ({}, 1, function()
			if vol.widget.visible
			then
				vol.container:set_widget(nil)
			else
				vol.container:set_widget(vol.widget)
			end
			vol.widget.visible = not vol.widget.visible
		end),
		awful.button ({}, 3, function()
			awful.util.spawn ("amixer sset Master toggle")
			vicious.force ({ vol.widget })
		end),
		awful.button ({}, 4, function()
			awful.util.spawn ("amixer sset Master 5+")
			vicious.force ({ vol.widget })
		end),
		awful.button ({}, 5, function()
			awful.util.spawn ("amixer sset Master 5-")
			vicious.force ({ vol.widget })
		end)
	))
	vol.widget = blingbling.progress_graph({ height = 18, width=10, graph_color=beautiful.graph_color })
	vol.widget.visible=false
	vol.container = wibox.layout.margin() --volwidget)
	vol.widget:set_graph_line_color("#555555")
	vol.widget.mixer =  terminal .. " -e alsamixer"
	vicious.register (vol.widget, vicious.widgets.volume, function (widget, args)
		vol.widget._current_level = args[1]
		if args[2] == "♩"
		then
			vol.widget._muted = true
			vol.widget:set_graph_color(beautiful.color_muted)
			vol.icon:set_image(beautiful.vol_off)
			return 100
		end
		vol.widget._muted = false
		vol.widget:set_graph_color(beautiful.graph_color)
		if args[1]>75
		then
			vol.icon:set_image(beautiful.vol3)
		elseif args[1]>50
		then
			vol.icon:set_image(beautiful.vol2)
		elseif args[1]>25
		then
			vol.icon:set_image(beautiful.vol1)
		else
			vol.icon:set_image(beautiful.vol0)
		end	
		return args[1]
		end, 5, "Master") -- relatively high update time, use of keys/mouse will force update

	vol.widget:buttons (awful.util.table.join (
		awful.button ({}, 1, function()
			awful.util.spawn (vol.widget.mixer)
		end),
		awful.button ({}, 3, function()
			awful.util.spawn ("amixer sset Master toggle")
			vicious.force ({ vol.widget })
		end),
		awful.button ({}, 4, function()
			awful.util.spawn ("amixer sset Master 5+")
			vicious.force ({ vol.widget })
		end),
		awful.button ({}, 5, function()
			awful.util.spawn ("amixer sset Master 5-")
			vicious.force ({ vol.widget })
		end)
	))

	return vol
end
