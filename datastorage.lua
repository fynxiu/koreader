--[[
    FYN: this file is only for preferences dir fetch,
    and has nothing to do with storage.
--]]
-- need low-level mechnism to detect android to avoid recursive dependency
local isAndroid, android = pcall(require, "android")
-- FYN: libkoreader-lfs.so
local lfs = require("libs/libkoreader-lfs")

local DataStorage = {}

local data_dir
local full_data_dir

-- FYN: get dir with memo, if this dir doesn't exist, then mkdir it
function DataStorage:getDataDir()
    if data_dir then return data_dir end

    if isAndroid then
        data_dir = android.getExternalStoragePath() .. "/koreader"
    elseif os.getenv("UBUNTU_APPLICATION_ISOLATION") then
        local app_id = os.getenv("APP_ID")
        local package_name = app_id:match("^(.-)_")
        -- confined ubuntu app has write access to this dir
        data_dir = string.format("%s/%s", os.getenv("XDG_DATA_HOME"), package_name)
    elseif os.getenv("APPIMAGE") or os.getenv("KO_MULTIUSER") then
        data_dir = string.format("%s/%s/%s", os.getenv("HOME"), ".config", "koreader")
    else
        data_dir = "."
    end
    if lfs.attributes(data_dir, "mode") ~= "directory" then
        lfs.mkdir(data_dir)
    end

    return data_dir
end

function DataStorage:getHistoryDir()
    return self:getDataDir() .. "/history"
end

function DataStorage:getSettingsDir()
    return self:getDataDir() .. "/settings"
end


function DataStorage:getFullDataDir()
    if full_data_dir then return full_data_dir end

    if string.sub(self:getDataDir(), 1, 1) == "/" then
        full_data_dir = self:getDataDir()
    elseif self:getDataDir() == "." then
        full_data_dir = lfs.currentdir()
    -- FYN: else missing, warning or
    end

    return full_data_dir
end

-- FYN: mkdir for all
local function initDataDir()
    local sub_data_dirs = {
        "cache", "clipboard",
        "data", "data/dict", "data/tessdata",
        "history", "ota",
        "screenshots", "settings", "styletweaks",
    }
    -- FYN: ipairs only integer key
    for _, dir in ipairs(sub_data_dirs) do
        local sub_data_dir = string.format("%s/%s", DataStorage:getDataDir(), dir)
        if lfs.attributes(sub_data_dir, "mode") ~= "directory" then
            lfs.mkdir(sub_data_dir)
        end
    end
end

initDataDir()

return DataStorage
