local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful =  require("awful")

module("widgets.net")

-- Net widget
function new()
	local net = {}
	vicious.cache(vicious.widgets.net)
	net.up_icon = wibox.widget.imagebox()
	net.up_icon:set_image(beautiful.widget_netup)
	net.down_icon = wibox.widget.imagebox()
	net.down_icon:set_image(beautiful.widget_netdown)
	net.up = wibox.widget.textbox()
	net.down = wibox.widget.textbox()
	net.up.mode=0
	net.down.mode=0
	vicious.register(net.down, vicious.widgets.net, function (widget, args)
		if net.down.mode == 0
		then
			return '<span color="#ff8800">' .. args['{eth0 down_kb}'] .. 'kb/s</span>'
		else
			return '<span color="#ffff00">' .. args['{eth0 rx_mb}'] .. 'Mb</span>'
		end
	end,5)
	vicious.register(net.up, vicious.widgets.net, function (widget, args)
		if net.up.mode == 0
		then
			return '<span color="#55ff55">' .. args['{eth0 up_kb}'] .. 'kb/s</span>'
		else
			return '<span color="#ff00ff">' .. args['{eth0 tx_mb}'] .. 'Mb</span>'
		end
	end,5)


	net.up_icon:buttons (awful.button ({}, 1, function()
		net.up.mode = 1 - net.up.mode
		vicious.force ({ net.up })
		end)
	)
	net.down_icon:buttons (awful.button ({}, 1, function()
		net.down.mode = 1 - net.down.mode
		vicious.force ({ net.down })
		end)
	)
	net.up:buttons (awful.button ({}, 1, function()
		netup.mode = 1 - netup.mode
		vicious.force ({ net.up })
		end)
	)
	net.down:buttons (awful.button ({}, 1, function()
		net.down.mode = 1 - net.down.mode
		vicious.force ({ net.down })
		end)
	)

	return net
end
