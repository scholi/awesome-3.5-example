local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful =  require("awful")
local setmetatable = setmetatable
module("widgets.net")

local net = {}

-- Net widget


function net:swap_mode()
	self.down.mode = 1 - self.down.mode
	self.up.mode = 1 - self.up.mode
	vicious.force ({ self.up, self.down })
end

function new()
	local self = setmetatable({}, net)
	vicious.cache(vicious.widgets.net)
	self.up_icon = wibox.widget.imagebox()
	self.up_icon:set_image(beautiful.widget_netup)
	self.down_icon = wibox.widget.imagebox()
	self.down_icon:set_image(beautiful.widget_netdown)
	self.up = wibox.widget.textbox()
	self.down = wibox.widget.textbox()
	self.up.mode=0
	self.down.mode=0
	vicious.register(self.down, vicious.widgets.net, function(widget, args)
		if self.down.mode == 0
		then
			return '<span color="#ff8800">' .. args['{eth0 down_kb}'] .. 'kb/s</span>'
		else
			return '<span color="#ffff00">' .. args['{eth0 rx_mb}'] .. 'Mb</span>'
		end
	end,5)
	vicious.register(self.up, vicious.widgets.net, function(widget, args)
		if self.up.mode == 0
		then
			return '<span color="#55ff55">' .. args['{eth0 up_kb}'] .. 'kb/s</span>'
		else
			return '<span color="#ff00ff">' .. args['{eth0 tx_mb}'] .. 'Mb</span>'
		end
	end,5)

	self.up_icon:buttons (awful.button ({}, 1, function()
		self.down.mode = 1 - self.down.mode
		self.up.mode = 1 - self.up.mode
		vicious.force ({ self.up, self.down })
	end))
	self.down_icon:buttons (awful.button ({}, 1,function()
		self.down.mode = 1 - self.down.mode
		self.up.mode = 1 - self.up.mode
		vicious.force ({ self.up, self.down })
	end))
	self.up:buttons (awful.button ({}, 1, function()
		self.down.mode = 1 - self.down.mode
		self.up.mode = 1 - self.up.mode
		vicious.force ({ self.up, self.down })
	end))
	self.down:buttons (awful.button ({}, 1, function()
		self.down.mode = 1 - self.down.mode
		self.up.mode = 1 - self.up.mode
		vicious.force ({ self.up, self.down })
	end))

	return self
end

