promise
=======

Lua promises

Supports lua coroutines and nginx light threads


local p = require 'promise'()

local id = p:start(function() return 'foo', 'bar' end)

local foo, bar = p:fetch(id)

if not foo then error(bar) end

id = p:start(function() return 'foo', 'bar' end)
local id2 = p:start(function() return 'baz', 'bat' end)

local results = p:all()

local firstResults = results[id]
local secondResults = results[id2]

id = p:start(function() return 'foo', 'bar' end)
local id2 = p:start(function() return 'baz', 'bat' end)

while true do
  local id, foo, bar = p:first()
  if not id then break end
  print(foo)
  print(bar)
end
