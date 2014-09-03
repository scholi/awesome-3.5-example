-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local blingbling = require("blingbling")
local vicious = require("vicious")
local bashets = require("bashets")

-- PATHES
local cfg_path = awful.util.getdir("config")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

env = "GTK_IM_MODULE=xim QT_IM_MODULE=xim _JAVA_AWT_WM_NONREPARENTING=1"

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
mytheme=awful.util.pread("echo -n $(cat " .. cfg_path .. "/mytheme 2>/dev/null || echo scholi)")
local theme_path = cfg_path .. "/themes/" .. mytheme .. "/theme.lua"
beautiful.init(theme_path)

--beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/japanese2/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = { "1sys","2www","3mail",
		  "4chat","5files","6vm",
		  "7","8","9float" },
	layout = { layouts[2],layouts[2],layouts[2],
		   layouts[2],layouts[2],layouts[2],
		   layouts[2],layouts[2],layouts[1] },
	bgcolor= { beautiful.bg1,beautiful.bg2,beautiful.bg1,beautiful.bg2,
	beautiful.bg1,beautiful.bg2,beautiful.bg1,beautiful.bg2,beautiful.bg1}
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mythememenu = {}

function theme_load(theme)
   local cfg_path = awful.util.getdir("config")
   awful.util.spawn_with_shell("echo \"" .. theme .. "\" > " .. cfg_path .. "/mytheme")
   awesome.restart()
end

function theme_menu()
   -- Liste vos fichiers de thème et remplit le tableau du menu
   local cmd = "for x in $(find " .. awful.util.getdir("config") .. "/themes/  -maxdepth 1 -mindepth 1 -type d ! -iname '.*'); do basename $x; done"

   local f = io.popen(cmd)

   for l in f:lines() do
	  local item = { l, function () theme_load(l) end }
	  table.insert(mythememenu, item)
   end

   f:close()
end

-- Génère votre tableau au (re)démarrage
theme_menu()

myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "edit theme", editor_cmd .. " " .. theme_path },
   { "switch themes", mythememenu},
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- TODO for future usage
--sp1 = wibox.widget.imagebox()
--sp1:set_image(beautiful.arr1)
--sp2 = wibox.widget.imagebox()
--sp2:set_image(beautiful.arr1)
--sp3 = wibox.widget.imagebox()
--sp3:set_image(beautiful.arr1)
sp4 = wibox.widget.imagebox()
sp4:set_image(beautiful.arr2)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

local colors_stops =  { {beautiful.green , 0},
                        {beautiful.orange, 0.75},
                        {beautiful.red, 0.90}
}

-- Create a Date/Calendar widget
mytextclock = awful.widget.textclock()
calendar = nil
local offset = 0

function remove_calendar()
        if calendar ~= nil then
            naughty.destroy(calendar)
            calendar = nil
            offset = 0
        end
end

function showcalendar(inc_offset)
        local save_offset = offset
        remove_calendar()
        if inc_offset == 666 then
                offset = 0
        else
                offset = save_offset + inc_offset
        end
        local datespec = os.date("*t")
        local date = datespec.year * 12 + datespec.month - 1 + offset
        date = (date % 12 + 1) .. " " .. math.floor(date / 12)
        cal = awful.util.pread("cal -m " .. date)
	if offset == 0 then cal = string.gsub(cal, "([\n ])(" .. datespec.day .. " )", "%1<span color='orange' font_weight='bold'>%2</span>") end
        calendar = naughty.notify({
                    text = '<span font-family="monospace">' .. cal .. '</span>',
                    timeout = 0, hover_timeout = 0.5, --height=130
        })
end

mytextclock:buttons(awful.util.table.join(
  awful.button({ }, 1, function () showcalendar(666) end, nil, "Show current month"),
  awful.button({ }, 4, function () showcalendar(-1) end, nil, "Show previous month"),
  awful.button({ }, 5, function () showcalendar(1) end, nil, "Show next month")
))

-- FS Widget
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.widget_hdd)

fshome = blingbling.value_text_box.new({height=18, width=40, v_margin=2})
fshome:set_values_text_color(colors_stops)
fshome:set_rounded_size(0.4)
fshome:set_background_color("#00000066")
fshome:set_label("/home $percent %")
vicious.register(fshome,vicious.widgets.fs,'${/home used_p}',120)

fsroot = blingbling.value_text_box.new({height=18, width=40, v_margin=2})
fsroot:set_values_text_color(colors_stops)
fsroot:set_rounded_size(0.4)
fsroot:set_background_color("#00000066")
fsroot:set_label("/ $percent %")
vicious.register(fsroot,vicious.widgets.fs,'${/ used_p}',120)

-- CPU widget
--tempwidget  = wibox.widget.textbox()
--bashets.register(cfg_path .. "/Tcpu.sh",{widget=tempwidget,separator=" ", update_time=20})
cpu_icon = wibox.widget.imagebox()
cpu_icon:set_image(beautiful.widget_cpu)
cpu_icon:buttons(awful.button ({}, 1, function()
	if cpu_graph.visible
	then
		cpucontainer:set_widget(nil)
	else
		cpucontainer:set_widget(cpu_graph)
	end
	cpu_graph.visible = not cpu_graph.visible
end))

cpu_graph = blingbling.line_graph({ height = 18, width = 100, graph_color=beautiful.graph_color, graph_line_color=beautiful.graph_line_color  })
vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)
cpu_graph.visible=false
cpucontainer = wibox.layout.margin()

mycore1=blingbling.progress_graph.new({height=18, width=6,h_margin=1})
vicious.register(mycore1, vicious.widgets.cpu, '$2',1)
mycore2=blingbling.progress_graph.new({height=18, width=6,h_margin=1})
vicious.register(mycore2, vicious.widgets.cpu, '$3',1)
mycore1:buttons(awful.button ({}, 1, function() awful.util.spawn(terminal .. " -e htop") end))
mycore2:buttons(awful.button ({}, 1, function() awful.util.spawn(terminal .. " -e htop") end))

-- MEM widget
mem_icon = wibox.widget.imagebox()
mem_icon:set_image(beautiful.widget_mem)
memwidget = blingbling.value_text_box.new({height=18, width=10, v_margin=2})
memwidget:set_label("$percent %")
mem_graph = blingbling.line_graph({ height = 18, width = 100, graph_color=beautiful.graph_color, graph_line_color=beautiful.graph_line_color  })
mem_graph.visible=false
vicious.register(mem_graph, vicious.widgets.mem, '$1', 2)
vicious.register(memwidget, vicious.widgets.mem, '$1', 2)
memcontainer = wibox.layout.margin(memwidget)
mem_icon:buttons(awful.button ({}, 1, function()
	mem_graph.visible = not mem_graph.visible
	if mem_graph.visible
	then
		memcontainer:set_widget(mem_graph)
	else
		memcontainer:set_widget(memwidget)
	end
end))

-- Net widget
vicious.cache(vicious.widgets.net)
netup_icon = wibox.widget.imagebox()
netup_icon:set_image(beautiful.widget_netup)
netdown_icon = wibox.widget.imagebox()
netdown_icon:set_image(beautiful.widget_netdown)
netup = wibox.widget.textbox()
netdown = wibox.widget.textbox()
netup.mode=0
netdown.mode=0
vicious.register(netdown, vicious.widgets.net, function (widget, args)
	if netdown.mode == 0
	then
		return '<span color="#ff8800">' .. args['{eth0 down_kb}'] .. 'kb/s</span>'
	else
		return '<span color="#ffff00">' .. args['{eth0 rx_mb}'] .. 'Mb</span>'
	end
end,5)
vicious.register(netup, vicious.widgets.net, function (widget, args)
	if netup.mode == 0
	then
		return '<span color="#55ff55">' .. args['{eth0 up_kb}'] .. 'kb/s</span>'
	else
		return '<span color="#ff00ff">' .. args['{eth0 tx_mb}'] .. 'Mb</span>'
	end
end,5)


netup_icon:buttons (awful.button ({}, 1, function()
	netup.mode = 1 - netup.mode
	vicious.force ({ netup })
	end)
)
netdown_icon:buttons (awful.button ({}, 1, function()
	netdown.mode = 1 - netdown.mode
	vicious.force ({ netdown })
	end)
)
netup:buttons (awful.button ({}, 1, function()
	netup.mode = 1 - netup.mode
	vicious.force ({ netup })
	end)
)
netdown:buttons (awful.button ({}, 1, function()
	netdown.mode = 1 - netdown.mode
	vicious.force ({ netdown })
	end)
)

-- Volume widget
vol_icon = wibox.widget.imagebox()
vol_icon:set_image(beautiful.widget_vol)
vol_icon:buttons (awful.util.table.join (
	awful.button ({}, 1, function()
		if volwidget.visible
		then
			volcontainer:set_widget(nil)
		else
			volcontainer:set_widget(volwidget)
		end
		volwidget.visible = not volwidget.visible
	end),
	awful.button ({}, 3, function()
		awful.util.spawn ("amixer sset Master toggle")
		vicious.force ({ volwidget })
	end),
	awful.button ({}, 4, function()
		awful.util.spawn ("amixer sset Master 5+")
		vicious.force ({ volwidget })
	end),
	awful.button ({}, 5, function()
		awful.util.spawn ("amixer sset Master 5-")
		vicious.force ({ volwidget })
	end)
))
volwidget = blingbling.progress_graph({ height = 18, width=10, graph_color=beautiful.graph_color })
volwidget.visible=false
volcontainer = wibox.layout.margin() --volwidget)
volwidget:set_graph_line_color("#555555")
volwidget.mixer = terminal .. " -e alsamixer"
vicious.register (volwidget, vicious.widgets.volume, function (widget, args)
	volwidget._current_level = args[1]
	if args[2] == "♩"
	then
		volwidget._muted = true
		volwidget:set_graph_color(beautiful.color_muted)
		vol_icon:set_image(beautiful.vol_off)
		return 100
	end
	volwidget._muted = false
	volwidget:set_graph_color(beautiful.graph_color)
	if args[1]>75
	then
		vol_icon:set_image(beautiful.vol3)
	elseif args[1]>50
	then
		vol_icon:set_image(beautiful.vol2)
	elseif args[1]>25
	then
		vol_icon:set_image(beautiful.vol1)
	else
		vol_icon:set_image(beautiful.vol0)
	end	
	return args[1]
	end, 5, "Master") -- relatively high update time, use of keys/mouse will force update

volwidget:buttons (awful.util.table.join (
	awful.button ({}, 1, function()
		awful.util.spawn (volwidget.mixer)
	end),
	awful.button ({}, 3, function()
		awful.util.spawn ("amixer sset Master toggle")
		vicious.force ({ volwidget })
	end),
	awful.button ({}, 4, function()
		awful.util.spawn ("amixer sset Master 5+")
		vicious.force ({ volwidget })
	end),
	awful.button ({}, 5, function()
		awful.util.spawn ("amixer sset Master 5-")
		vicious.force ({ volwidget })
	end)
))

--bashets.start()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(1,s,layouts) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1,s,layouts) end),
                           awful.button({ }, 4, function () awful.layout.inc(1,s,layouts) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1,s,layouts) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons,{bg_empty=beautiful.bg2},nil,wibox.layout.fixed.horizontal())

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
--    left_layout:add(sp1)
--    left_layout:add(sp2)
--    left_layout:add(sp3)
   left_layout:add(sp4)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(cpu_icon)
    right_layout:add(mycore1)
    right_layout:add(mycore2)
--    right_layout:add(tempwidget)
    right_layout:add(cpucontainer)
    right_layout:add(mem_icon)
    right_layout:add(memcontainer)
    right_layout:add(netup_icon)
    right_layout:add(netup)
    right_layout:add(netdown_icon)
    right_layout:add(netdown)
    right_layout:add(vol_icon)
    right_layout:add(volcontainer)
    right_layout:add(fsicon)
    right_layout:add(fsroot)
    right_layout:add(fshome)
--    right_layout:add(volume_bar)
    right_layout:add(mytextclock)
--    right_layout:add(my_cal)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- generate and add the 'run or raise' key bindings to the globalkeys table
require("aweror")
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    awful.key({ modkey,           }, "b", function ()
	mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),
--    awful.key({ }, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/screenshots/ 2>/dev/null'") end),

    -- System cmd
    awful.key({ modkey, "Control" }, "Escape", function() awful.util.spawn("systemctl poweroff") end),
    awful.key({ modkey, "Control" }, "l", function() awful.util.spawn("xscreensaver-command -lock") end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

   -- Sound Controle
   awful.key({     }, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer set Master 5%+", false) end),
   awful.key({     }, "XF86AudioLowerVolume", function() awful.util.spawn("amixer set Master 5%-", false) end),
   awful.key({     }, "XF86AudioMute", function() awful.util.spawn("amixer set Master toggle", false) end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(1,s,layouts) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1,s,layouts) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    awful.key({ modkey }, "y", function () run_or_raise("google-chrome", { name= "Google Chrome" }) end),
    awful.key({ modkey }, "c", function () run_or_raise("pcmanfm", { class= "Pcmanfm" }) end),
    awful.key({ modkey }, "e", function () run_or_raise("eaglemode", { class= "EagleMode" }) end),
    awful.key({ modkey }, "g", function () run_or_raise("google-chrome --app='http://mail.google.com/mail/'", { name= "Gmail" }) end)
	
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey, "Control" }, "t", function (c)
       -- toggle titlebar
       awful.titlebar.toggle(c)
    end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end)
-- Following commands are taken over by cairo-cmpmgr (launched from ~/.xinit)
--	awful.key({ modkey }, "Next", function(c)
--		awful.util.spawn("transset-df --actual --inc 0.01")
--	end),
--	awful.key({ modkey }, "Prior", function(c)
--		awful.util.spawn("transset-df --actual --dec 0.01")
--	end)
	)
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox/Chrome to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Google-chrome" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Pcmanfm" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "EagleMode" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "XTerm" },
      properties = { opacity = 0.8 } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
