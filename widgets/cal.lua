local awful = require("awful")

module("widgets.cal")

-- Create a Date/Calendar widget

local cal = {}

function new()
	local self = awful.widget.textclock()
	self.calendar = nil
	self.offset = 0
	self:buttons(awful.util.table.join(
	  awful.button({ }, 1, function () self:showcalendar(666) end, nil, "Show current month"),
	  awful.button({ }, 4, function () self:showcalendar(-1) end, nil, "Show previous month"),
	  awful.button({ }, 5, function () self:showcalendar(1) end, nil, "Show next month")
	))
	return self
end

function cal:remove_calendar()
        if self.calendar ~= nil then
            naughty.destroy(self.calendar)
            self.calendar = nil
            self.offset = 0
        end
end

function cal:showcalendar(inc_offset)
        self.save_offset = self.offset
        self:remove_calendar()
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
