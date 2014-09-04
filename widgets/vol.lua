local beautiful = require("beautiful")
local awful = require("awful")
local vicious = require("vicious")
local blingbling = require("blingbling")
local wibox = require("wibox")
local setmetatable = setmetatable

module("widgets.vol")

local vol = { }
vol.__index = vol

-- Volume widget
function new(terminal)
	local self=setmetatable({},vol)
	self.icon = wibox.widget.imagebox()
	self.icon:set_image(beautiful.widget_vol)
	self.icon:buttons (awful.util.table.join (
		awful.button ({}, 1, function()
			if self.visible
			then
				self.container:reset()
			else
				for i = 1,#(self.widget)
				do
				  self.container:add(self.widget[i])
				end
			end
			self.visible = not self.visible
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
	vol.widget = {}
	vol.visible=false
	vol.container = wibox.layout.fixed.horizontal()
	vol.terminal=terminal
	self.mixer =  terminal .. " -e alsamixer"
	return self
end

function vol:add(channel)
	local i = #(self.widget) + 1
	self.widget[i] = blingbling.progress_graph({ height = 18, width=10, graph_color=beautiful.graph_color })
	self.widget[i]:set_graph_line_color("#555555")
	self.widget[i].channel=channel
	vicious.register (self.widget[i], vicious.widgets.volume, function (widget, args)
		self.widget[i]._current_level = args[1]
		if args[2] == "♩"
		then
			self.widget[i]._muted = true
			self.widget[i]:set_graph_color(beautiful.color_muted)
			if self.widget[i].channel == "Master" then self.icon:set_image(beautiful.vol_off) end
			return 100
		end
		self.widget[i]._muted = false
		self.widget[i]:set_graph_color(beautiful.graph_color)
		if self.widget[i].channel == "Master"
		then
			if args[1]>75
			then
				self.icon:set_image(beautiful.vol3)
			elseif args[1]>50
			then
				self.icon:set_image(beautiful.vol2)
			elseif args[1]>25
			then
				self.icon:set_image(beautiful.vol1)
			else
				self.icon:set_image(beautiful.vol0)
			end
		end
		return args[1]
		end, 5, channel) -- relatively high update time, use of keys/mouse will force update

	self.widget[i]:buttons (awful.util.table.join (
		awful.button ({}, 1, function()
			awful.util.spawn (self.mixer)
		end),
		awful.button ({}, 3, function()
			awful.util.spawn ("amixer sset " .. channel .. " toggle")
			vicious.force ({ self.widget[i] })
		end),
		awful.button ({}, 4, function()
			awful.util.spawn ("amixer sset " .. channel .. " 5+")
			vicious.force ({ self.widget[i] })
		end),
		awful.button ({}, 5, function()
			awful.util.spawn ("amixer sset " .. channel .. " 5-")
			vicious.force ({ self.widget[i] })
		end)
	))
	if self.visible then
		self.container:add(self.widget[i])
	end
end
