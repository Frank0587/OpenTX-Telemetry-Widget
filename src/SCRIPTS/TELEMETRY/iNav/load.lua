-- OpenTX log loader

local config, data, FILE_PATH = ...

-- Load config for model
fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat")
if fh ~= nil then
   for i = 1, #config do
      local tmp = io.read(fh, config[i].c)
      if tmp ~= "" then
	 config[i].v = config[i].d == nil and math.min(tonumber(tmp), config[i].x == nil and 1 or config[i].x) or tmp * 0.1
      end
   end
   io.close(fh)
end
fh = nil
collectgarbage()

-- Look for language override
fh = io.open(FILE_PATH .. "cfg/lang.dat")
if fh ~= nil then
   local tmp = io.read(fh, 2)
   io.close(fh)
   data.lang = tmp
   data.voice = tmp
end
fh = nil
collectgarbage()

local log = getDateTime()

config[34].x = -1
local mbase = data.etx and model.getInfo().name or string.gsub(model.getInfo().name, " ", "_")
local path = "/LOGS/" .. mbase .. "-20"
for days = 1, 90 do
   local logDate = string.sub(log.year, 3) .. "-" .. string.sub("0" .. log.mon, -2) .. "-" .. string.sub("0" .. log.day, -2)
   local fh = io.open(path .. logDate .. ".csv")
   if fh ~= nil then
      io.close(fh)
      fh = nil
      collectgarbage()
      config[34].x = config[34].x + 1
      config[34].l[config[34].x] = logDate
      if config[34].x == 9 then break end
   end
   
   log.day = log.day - 1
   if log.day == 0 then
      log.day = 31
      log.mon = log.mon - 1
      if log.mon == 0 then
	   log.mon = 12
	   log.year = log.year - 1
      end
   end
end
return
