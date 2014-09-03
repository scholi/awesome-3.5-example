local blingbling = require("blingbling")
local wibox = require("wibox")
local vicious = require("vicious")
local beautiful = require("beautiful")
local setmetatable = setmetatable
local awful = require("awful")
module("widgets.fs")

local fs = { }
fs.__index = fs

-- FS Widget
function new(visible)
    if visible == nil then visible = true end
    local self = setmetatable({}, fs)
    self.icon = wibox.widget.imagebox()
    self.icon:set_image(beautiful.widget_hdd)
    self.container = wibox.layout.fixed.horizontal()
    self.visible = visible
    self.icon:buttons(awful.button ({}, 1, function()
        if self.visible
        then
            self.container:reset()
        else
            for i = 1,#(self.X)
            do
                self.container:add(self.X[i])
            end
        end
        self.visible = not self.visible
   end))
   self.X={}
   return self
end

function fs:add(path)
  local i=#(self.X)+1
  self.X[i] = blingbling.value_text_box.new({height=18, width=40, v_margin=2})
  self.X[i]:set_values_text_color(beautiful.colors_stops)
  self.X[i]:set_rounded_size(0.4)
  self.X[i]:set_background_color("#00000066")
  self.X[i]:set_label(path .. " $percent %")
  vicious.register(self.X[i],vicious.widgets.fs,'${' .. path ..' used_p}',120)
  if self.visible then
    self.container:add(self.X[i])
  end
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
