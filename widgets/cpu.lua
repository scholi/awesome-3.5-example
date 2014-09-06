local blingbling = require("blingbling")
local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")
local setmetatable = setmetatable
local bashets = require("bashets")
module("widgets.cpu")

-- CPU widget
local cpu = {}

function new(terminal)
  local self = setmetatable({}, cpu)
  local cfg_path = awful.util.getdir("config")
  self.terminal = terminal
  self.icon = wibox.widget.imagebox()
  self.icon:set_image(beautiful.widget_cpu)
  self.icon:buttons(awful.button ({}, 1, function()
	if self.graph.visible
	then
		self.container:set_widget(nil)
	else
		self.container:set_widget(self.graph)
	end
	self.graph.visible = not self.graph.visible
  end))
  self.temp  = wibox.widget.textbox()
  bashets.register(cfg_path .. "/Tcpu.sh",{widget=self.temp,separator=" ", update_time=20})

  self.graph = blingbling.line_graph({ height = 18, width = 100, graph_color=beautiful.graph_color, graph_line_color=beautiful.graph_line_color  })
  vicious.register(self.graph, vicious.widgets.cpu,'$1',2)
  self.graph.visible=false
  self.container = wibox.layout.margin()

  self.core1=blingbling.progress_graph.new({height=18, width=6,h_margin=1})
  vicious.register(self.core1, vicious.widgets.cpu, '$2',1)
  self.core2=blingbling.progress_graph.new({height=18, width=6,h_margin=1})
  vicious.register(self.core2, vicious.widgets.cpu, '$3',1)
  self.core1:buttons(awful.button ({}, 1, function() awful.util.spawn(self.terminal .. " -e htop") end))
  self.core2:buttons(awful.button ({}, 1, function() awful.util.spawn(self.terminal .. " -e htop") end))

  return self
end
