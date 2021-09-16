local USAGE = [[

dump [command] [key1] [key1] [keyN] :

  [global] - dump global table (`_G`).

  [registery] - dump lua debug registery table.

  [filename] - dump already loaded package and its return table .

  --

  `keyX` means we can get `deep value` like `table[key1][key2]..[keyN]`

  e.g : 
   1. dump cf wait
   2. dump global string
]]

local function DUMPALL(name, ROOT)
  local KSIZE,  T_USERDATA, T_STRING, T_FUNCTION, T_NUMBER, T_THREAD, T_BOOLEAN, T_TABLE = 0, 0, 0, 0, 0, 0, 0, 0
  local counter = {}
  local content = {}
  for k, v in pairs(ROOT) do
    KSIZE = KSIZE + 1
    local key = tostring(k)
    local value = nil
    if type(v) == 'string' then
      T_STRING = T_STRING + 1
      value = "'" .. v .. "'"
    elseif type(v) =="boolean" then
      T_BOOLEAN = T_BOOLEAN + 1
      value = v and "true" or "false"
    elseif type(v) == 'userdata' then
      T_USERDATA = T_USERDATA + 1
      value = tostring(v)
    elseif type(v) == 'function' then
      T_FUNCTION = T_FUNCTION + 1
      local info = debug.getinfo(v)
      local val = false
      if info.short_src ~= '[C]' then
        val = tostring(v) .. "(".. info.short_src .. ":" .. info.linedefined .. ")"
      end
      value = val or tostring(v)
    elseif type(v) == 'number' then
      T_NUMBER = T_NUMBER + 1
      value = v
    elseif type(v) == 'thread' then
      T_THREAD = T_THREAD + 1
      value = tostring(v)
    elseif type(v) == 'table' then
      T_TABLE = T_TABLE + 1
      value = tostring(v)
    end
    content[#content+1] = '[' .. key .. ']' .. ' = ' .. value
  end
  counter[#counter+1] = "total keys count: " .. KSIZE
  counter[#counter+1] = T_STRING > 0 and ("string value count: " .. T_STRING) or nil
  counter[#counter+1] = T_NUMBER > 0 and ("number value count: " .. T_NUMBER) or nil
  counter[#counter+1] = T_BOOLEAN > 0 and ("boolean value count: " .. T_BOOLEAN) or nil
  counter[#counter+1] = T_FUNCTION > 0 and ("function value count: " .. T_FUNCTION) or nil
  counter[#counter+1] = T_USERDATA > 0 and ("usedata value count: " .. T_USERDATA) or nil
  counter[#counter+1] = T_TABLE > 0 and ("table value count: " .. T_TABLE) or nil
  local tab = {"\r\ncounter: \r\n  " .. table.concat(counter, '\r\n  '), name .. "{\r\n  " .. table.concat(content, "\r\n  ") .. "\r\n}"}
  return table.concat(tab, "\r\n\r\n") .. "\r\n"
end

local function DUMPVALUE(k, v)
  if type(v) == 'string' then
    v = "'" .. v .. "'"
  elseif type(v) =="boolean" then
    v = v and "true" or "false"
  elseif type(v) == 'userdata' then
    v = tostring(v)
  elseif type(v) == 'function' then
    local info = debug.getinfo(v)
    local val = false
    if info.short_src ~= '[C]' then
      val = tostring(v) .. "(".. info.short_src .. ":" .. info.linedefined .. ")"
    end
    v = val or tostring(v)
  elseif type(v) == 'number' then
    v = tostring(v)
  elseif type(v) == 'thread' then
    v = tostring(v)
  else
    v = tostring(v)
  end
  return "\r\n" .. "['" .. k .. "']" .. " = " .. v .. "\r\n"
end

return function (name, ...)
  if not name then
    return USAGE
  end
  local ROOT
  if name == 'global' then
    ROOT = _ENV or _G
  elseif name == 'registery' then
    ROOT = debug.getregistry ()
  else
    local t = package.loaded[name]
    if not t then
      return "\r\nCan't import this package.\r\n"
    end
    ROOT = t
  end
  if type(ROOT) ~= 'table' then
    return tostring(ROOT)
  end
  local args
  local argv = select("#", ...)
  if argv > 0 then
    args = {...}
  end
  for level = 1, argv do
    local tab = ROOT[args[level]]
    if type(tab) ~= 'table' then
      return DUMPVALUE(args[level], tab)
    end
    ROOT = tab
  end
  return DUMPALL(args and args[#args] or name, ROOT)
end
