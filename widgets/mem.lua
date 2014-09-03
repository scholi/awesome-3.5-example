local wibox = require("wibox")
local blingbling = require("blingbling")
local beautiful = require("beautiful")
local wibox = require("wibox")
local vicious = require("vicious")
local awful =  require("awful")

module("widgets.mem")

function new()
	local mem={}
	mem.icon = wibox.widget.imagebox()
	mem.icon:set_image(beautiful.widget_mem)
	mem.widget = blingbling.value_text_box.new({height=18, width=10, v_margin=2})
	mem.widget:set_label("$percent %")
	mem.graph = blingbling.line_graph({ height = 18, width = 100, graph_color=beautiful.graph_color, graph_line_color=beautiful.graph_line_color  })
	mem.graph.visible=false
	vicious.register(mem.graph, vicious.widgets.mem, '$1', 2)
	vicious.register(mem.widget, vicious.widgets.mem, '$1', 2)
	mem.container = wibox.layout.margin(mem.widget)
	mem.icon:buttons(awful.button ({}, 1, function()
		mem.graph.visible = not mem.graph.visible
		if mem.graph.visible
		then
			mem.container:set_widget(mem.graph)
		else
			mem.container:set_widget(mem.widget)
		end
	end))

	return mem
end
