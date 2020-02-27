-- haven.                 
-- 
-- 
--         a safe space?
-- 
-- 
--
-- @LFSaw            [20200227]
-- 
-- E1 overall volume
-- E2 left param (freq | fb_sign)
-- E3 right param (amp | fb)
-- K2 up
-- K3 down
-- K1 shift
-- 
-- https://llllllll.co/t/haven/

engine.name = "Haven"

local sel = 1
local shift = false

-- knobs and encoders
local k1 = 1
local k2 = 2
local k3 = 3
local e1 = 1
local e2 = 2
local e3 = 3

-- selections
local ctlLo = 1
local ctlHi = 2
local ctlFdbck = 3
local ctlIn = 4
local ctlReverb = 5


function init()
  params:add{
    type="control",
    id="freq1",
    controlspec=controlspec.new(1, 800, "exp", 0, 20, "Hz"),
    action=engine.freq1,
  }

  params:add{
    type="control",
    id="amp1",
    controlspec=controlspec.new(-90, 0, "db", 0, -90, "dB"),
    action=engine.amp1,
  }

  params:add_separator()

  params:add{
    type="control",
    id="freq2",
    controlspec=controlspec.new(400, 12000, "exp", 0, 4000, "Hz"),
    action=engine.freq2,
  }

  params:add{
    type="control",
    id="amp2",
    controlspec=controlspec.new(-90, 0, "db", 0, -90, "dB"),
    action=engine.amp2,
  }

  params:add_separator()

  params:add{
    type="control",
    id="in_amp",
    controlspec=controlspec.new(-90, 0, "db", 0, -90, "dB"),
    action=engine.inAmp,
  }

  params:add_separator()

  params:add{
    type="control",
    id="fdbckSign",
    controlspec=controlspec.new(-1, 1, "linear", 1, 1, ""),
    action=engine.fdbckSign,
  }

  params:add{
    type="control",
    id="fdbck",
    controlspec=controlspec.new(0, 1, "linear", 0, 0, ""),
    action=engine.fdbck,
  }

  params:add_separator()

  params:add{
    type="control",
    id="rev_level",
    controlspec=controlspec.new(-math.huge, 18, "db", 0, 0, "dB"),
    action=function(value) mix:set("rev_eng_input", value) end,
  }

  params:add{
    type="control",
    id="global_amp",
    controlspec=controlspec.new(-90, 0, "db", 0, 0, "dB"),
    action=engine.globalAmp,
  }

  params:bang()

  local screen_timer = metro.init()
  screen_timer.time = 1 / 15
  screen_timer.event = function() redraw() end
  screen_timer:start()
end

function redraw()
  screen.clear()
  screen.aa(1)
  -- screen.font_face(3)
  screen.font_size(8)
  screen.level(15)

  screen.level(2)
  screen.move(128, 8)
  if params:string("global_amp") == "-90.0 dB" then
    screen.text("-inf dB")
  else
    screen.text_right(""..params:string("global_amp"))
  end


  screen.level(sel == ctlLo and 15 or 2)
  screen.move(12, 24)
  screen.text("lo: ")
  screen.move_rel(46, 0)
  local val = params:get("freq1") / 4000
  screen.text_right(params:string("freq1"))
  screen.move_rel(45, 0)
  if params:string("amp1") == "-90.0 dB" then
    screen.text_right("-inf dB")
  else
    screen.text_right(params:string("amp1"))
  end

  screen.level(sel == ctlHi and 15 or 2)
  screen.move(12, 32)
  screen.text("hi: ");
  screen.move_rel(46, 0)
  screen.text_right(params:string("freq2"))
  screen.move_rel(45, 0)
  if params:string("amp2") == "-90.0 dB" then
    screen.text_right("-inf dB")
  else
    screen.text_right(params:string("amp2"))
  end

  screen.level(sel == ctlFdbck and 15 or 2)
  screen.move(12, 40)
  screen.text("fdbck:")
    screen.move_rel(20, 0)
  if params:get("fdbckSign") == -1 then
    screen.text("(-)")
  else
    screen.text("(+)")
  end
  screen.move_rel(36, 0)
  screen.text_right(params:string("fdbck"))

  screen.level(sel == ctlIn and 15 or 2)
  screen.move(12, 48)
  screen.text("in: ");
  screen.move_rel(92, 0)
  if params:string("in_amp") == "-90.0 dB" then
    screen.text_right("-inf dB")
  else
    screen.text_right(params:string("in_amp"))
  end
  
  screen.level(sel == ctlReverb and 15 or 2)
  screen.move(12, 56)
  screen.text("reverb:")
  screen.move_rel(75, 0)
  screen.text_right(params:string("rev_level"))

  screen.update()
end


function key(n, val)
  if n == k1 then
    shift = (val == 1)
  end

  if n == k3 and val == 1 then
    sel = sel + 1
    -- wrap cycle around
    sel = ((sel-1) % 5) + 1
    redraw()
  elseif n == k2 and val == 1 then
    sel = sel - 1
    -- wrap cycle around
    sel = ((sel-1) % 5) + 1
  end
end

function enc(n, delta)
  local delta = delta

  if n == e1 then
    -- mix:delta("output", delta)
    if shift then delta = delta / 10 end
    params:delta("global_amp", delta)
  end

  if sel == ctlLo then
    if n == e2 then
      if shift then delta = delta / 100 end
      params:delta("freq1", delta)
    end
    if n == e3 then
      if shift then delta = delta / 10 end
      params:delta("amp1", delta)
    end
  elseif sel == ctlHi then
    if n == e2 then
      if shift then delta = delta / 100 end
      params:delta("freq2", delta)
    end
    if n == e3 then
      if shift then delta = delta / 10 end
      params:delta("amp2", delta)
    end
  elseif sel == ctlFdbck then
    if n == e3 then
      if shift then delta = delta / 10 end
      params:delta("fdbck", delta)
    end
    if n == e2 then
      if delta >= 0 then
        params:set("fdbckSign", 1)
      else
        params:set("fdbckSign", -1)
      end
    end
  elseif sel == ctlIn then
    if n == e3 then
      if shift then delta = delta / 100 end
      params:delta("in_amp", delta)
    end
  elseif sel == ctlReverb then
    if n == e3 then
      if shift then delta = delta / 100 end
      params:delta("rev_level", delta)
    end
  end
end
