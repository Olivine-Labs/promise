local uuid = require 'uuid'
local spawn = ngx and ngx.thread.spawn or coroutine.create
local wait = ngx and ngx.thread.wait or coroutine.resume

local promise = {}

function promise:start(fn)
  local id = uuid.new()
  local thread, err = spawn(function()
    return id, fn()
  end)
  if not thread then return nil, err end
  self.threads[id] = thread
  return id
end

function promise:fetch(id)
  if not self.threads[id] then return nil, "no such thread" end
  local res = {wait(self.threads[id])}

  if coroutine.status(self.threads[id]) == "dead" then
    self.threads[id] = nil
  end

  if res[1] then
    local actualId = res[2]
    if id ~= actualId then error('something really bad happened') end
    return unpack(res, 3)
  else
    return nil, "failed to fetch result: "..res[2]
  end
end

function promise:all(...)
  local ids = {...}
  if #ids == 0 then
    for k in pairs(self.threads) do
      ids[#ids+1] = k
    end
  end
  local ret = {}
  for _, v in pairs(ids) do
    ret[v] = {self:fetch(v)}
  end
  return ret
end

function promise:first()
  if next(self.threads) == nil then return nil, "nothing to fetch" end
  local list = {}
  for _, v in pairs(self.threads) do
    list[#list+1] = v
  end
  local res = {wait(unpack(list))}

  if res[1] then
    local id = res[2]
    if coroutine.status(self.threads[id]) == "dead" then
      self.threads[id] = nil
    end

    return unpack(res, 2)
  else
    return nil, "first fetch failed"
  end
end

return function()
  return setmetatable({threads = {}}, {__index=promise})
end
