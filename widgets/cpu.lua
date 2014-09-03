local blingbling = require("blingbling")
local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")

module("widgets.cpu")

-- CPU widget
--tempwidget  = wibox.widget.textbox()
--bashets.register(cfg_path .. "/Tcpu.sh",{widget=tempwidget,separator=" ", update_time=20})

function new(terminal)
  local cpu = {}
  cpu.icon = wibox.widget.imagebox()
  cpu.icon:set_image(beautiful.widget_cpu)
  cpu.icon:buttons(awful.button ({}, 1, function()
	if cpu.graph.visible
	then
		cpu.container:set_widget(nil)
	else
		cpu.container:set_widget(cpu.graph)
	end
	cpu.graph.visible = not cpu.graph.visible
  end))

  cpu.graph = blingbling.line_graph({ height = 18, width = 100, graph_color=beautiful.graph_color, graph_line_color=beautiful.graph_line_color  })
  vicious.register(cpu.graph, vicious.widgets.cpu,'$1',2)
  cpu.graph.visible=false
  cpu.container = wibox.layout.margin()

  cpu.core1=blingbling.progress_graph.new({height=18, width=6,h_margin=1})
  vicious.register(cpu.core1, vicious.widgets.cpu, '$2',1)
  cpu.core2=blingbling.progress_graph.new({height=18, width=6,h_margin=1})
  vicious.register(cpu.core2, vicious.widgets.cpu, '$3',1)
  cpu.core1:buttons(awful.button ({}, 1, function() awful.util.spawn(terminal .. " -e htop") end))
  cpu.core2:buttons(awful.button ({}, 1, function() awful.util.spawn(terminal .. " -e htop") end))

  return cpu
end
