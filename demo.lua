id = "lc.script.gm"
name = "A-群管"
author = "LC"
version = "1.0"
info = "提供基本的群管功能, 对其他脚本提供api"
ui = "app.html"
icon = ""

local menv = {
  inited = false,
  rootpath = ""
}

function handleMessage(api)
  init(api)
  handleMessage(api)
end

function init(api)
  api:logI(_VERSION)
  if not menv.inited then
    menv.inited = true
    menv.rootpath = api:getRootPath()

    package.path = menv.rootpath .. "documents/?.lua;" .. package.path

    require "app"
  end
end

--Mock for Test--
if os.getenv("OS") and os.getenv("OS"):lower():find("windows") ~= 0 then
  --MSG--
  local MSG = {uin = 123456, groupid = 7890, context = "gm"}

  function MSG:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
  end

  function MSG:clearMsg()
    self.context = ""
  end

  function MSG:getTextMsg()
    return self.context
  end

  --API--
  local API = {msg = MSG:new()}

  function API:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
  end

  function API:logI(info)
    print("[info]: " .. tostring(info))
  end

  function API:getRootPath()
    return "./"
  end

  function API:getLibPath()
    return "./lib/"
  end

  function API:send()
    print("Send:【" .. self.msg:getTextMsg() .. "】")
  end

  function API:robot()
    return 23456678
  end

  function API:at(index)
  end

  function API:atCnt()
  end

  function API:get(url)
  end

  function API:post(url)
  end

  function API:load(path, key, value)
    print("Load:【" .. path .. "|" .. key .. "|" .. value .. "】")
  end

  function API:save(path, key, value)
    print("Save:【" .. path .. "|" .. key .. "|" .. value .. "】")
  end

  function API:add(mtype, msg)
    self.msg.context = mtype .. ":" .. msg
  end
  
  function API:getType()
    return -1
  end
  --Mock for handleMessage---
  handleMessage(API:new())
end
