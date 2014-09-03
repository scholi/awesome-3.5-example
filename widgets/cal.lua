local awful = require("awful")
local naughty = require("naughty")
local os = require("os")
local math = require("math")
local string = require("string")

local setmetatable = setmetatable

module("widgets.cal")

-- Create a Date/Calendar widget

local cal = {}

local function remove_calendar(self)
        if self.calendar ~= nil then
            naughty.destroy(self.calendar)
            self.calendar = nil
            self.offset = 0
        end
end

local function show_calendar(self,inc_offset)
        self.save_offset = self.offset
        remove_calendar(self)
        if inc_offset == 666 then
                self.offset = 0
        else
                self.offset = self.save_offset + inc_offset
        end
        local datespec = os.date("*t")
        local date = datespec.year * 12 + datespec.month - 1 + self.offset
        date = (date % 12 + 1) .. " " .. math.floor(date / 12)
        cal = awful.util.pread("cal -m " .. date)
	if self.offset == 0 then cal = string.gsub(cal, "([\n ])(" .. datespec.day .. " )", "%1<span color='orange' font_weight='bold'>%2</span>") end
        self.calendar = naughty.notify({
                    text = '<span font-family="monospace">' .. cal .. '</span>',
                    timeout = 0, hover_timeout = 0.5, --height=130
        })
end

function new()
	local self = setmetatable({}, cal)
	self.widget = awful.widget.textclock()
	self.calendar = nil
	self.offset = 0
	self.widget:buttons(awful.util.table.join(
	  awful.button({ }, 1, function () show_calendar(self,666) end, nil, "Show current month"),
	  awful.button({ }, 4, function () show_calendar(self,-1) end, nil, "Show previous month"),
	  awful.button({ }, 5, function () show_calendar(self,1) end, nil, "Show next month")
	))
	return self
end

