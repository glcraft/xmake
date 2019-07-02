--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        io.lua
--

-- define module
local io    = io or {}
local _file = _file or io.file or {}

-- load modules
local path   = require("base/path")
local table  = require("base/table")
local string = require("base/string")

-- save original apis
io._open    = io._open or io.open

_file._read = _file._read or _file.read

-- read data from file
function _file:read(fmt, opt)
    opt = opt or {}
    return self:_read(fmt, opt.continuation)
end

-- read all lines from a file
function _file:lines(opt)

    opt = opt or {}
    return function()
        local l = self:read("l", opt)
        if not l and opt.close_on_finished then
            self:close()
        end
        return l
    end
end

-- print file
function _file:print(...)
    return self:write(string.format(...), "\n")
end

-- printf file
function _file:printf(...)
    return self:write(string.format(...))
end

-- save object
function _file:save(object)
    local str, errors = string.serialize(object, false)
    if str then
        self:write(str)
    end
    return str, errors
end

-- load object
function _file:load()
    local data = self:read("*all")
    if data and type(data) == "string" then
        return data:deserialize()
    end
end

-- read all lines from file
function io.lines(filepath, opt)

    opt = opt or {}

    if opt.close_on_finished == nil then
        opt.close_on_finished = true
    end

    -- open file
    local file = io.open(filepath, "r", opt)
    if not file then
        -- error
        return function() return nil end
    end

    return file:lines(opt)
end

-- read all data from file
function io.readfile(filepath, opt)

    opt = opt or {}

    -- open file
    local file = io.open(filepath, "r", opt)
    if not file then
        -- error
        return nil, string.format("open %s failed!", filepath)
    end

    -- read all
    local data, err = file:read("*all", opt)

    -- exit file
    file:close()

    -- ok?
    return data, err
end

function io.read(fmt, opt)
    return io.stdin:read(fmt, opt)
end

function io.write(...)
    io.stdout:write(...)
end

function io.print(...)
    return io.stdout:print(...)
end

function io.printf(...)
    return io.stdout:printf(...)
end

function io.flush()
    return io.stdout:flush()
end

-- write data to file
function io.writefile(filepath, data, opt)

    opt = opt or {}

    -- open file
    local file = io.open(filepath, "w", opt)
    if not file then
        return false, string.format("open %s failed!", filepath)
    end

    -- write all
    file:write(data)

    -- exit file
    file:close()

    -- ok?
    return true
end

-- isatty
function io.isatty(fd)
    fd = fd or io.stdout
    return fd:isatty()
end

-- replace the original open interface
function io.open(filepath, mode, opt)

    -- check
    assert(filepath)

    mode = mode or "r"
    opt = opt or {}

    -- open it
    local handle = io._open(path.translate(filepath), mode .. (opt.encoding or ""))
    if not handle then
        return nil, string.format("failed to open %s", filepath)
    end

    -- ok?
    return handle
end

-- close file
function io.close(file)
    return (file or io.stdout):close()
end

-- save object the the given filepath
function io.save(filepath, object, opt)

    -- check
    assert(filepath and object)

    opt = opt or {}

    -- ensure directory
    local dir = path.directory(filepath)
    if not os.isdir(dir) then
        os.mkdir(dir)
    end

    -- open the file
    local file = io.open(filepath, "w", opt)
    if not file then
        -- error
        return false, string.format("open %s failed!", filepath)
    end

    -- save object to file
    local ok, errors = file:save(object)
    if not ok then
        -- error
        file:close()
        return false, string.format("save %s failed, %s!", filepath, errors)
    end

    -- close file
    file:close()

    -- ok
    return true
end
 
-- load object from the given file
function io.load(filepath, opt)

    -- check
    assert(filepath)

    opt = opt or {}

    -- open the file
    local file = io.open(filepath, "r", opt)
    if not file then
        -- error
        return nil, string.format("open %s failed!", filepath)
    end

    -- load object
    local result, errors = file:load()

    -- close file
    file:close()

    -- ok?
    return result, errors
end

-- gsub the given file and return replaced data
function io.gsub(filepath, pattern, replace, opt)

    opt = opt or {}

    -- read all data from file
    local data, errors = io.readfile(filepath, opt)
    if not data then return nil, 0, errors end

    -- replace it
    local count = 0
    if type(data) == "string" then
        data, count = data:gsub(pattern, replace)
    else
        return nil, 0, string.format("data is not string!")
    end

    -- replace ok?
    if count ~= 0 then
        -- write all data to file
        local ok, errors = io.writefile(filepath, data, opt)
        if not ok then return nil, 0, errors end
    end

    -- ok
    return data, count
end

-- cat the given file
function io.cat(filepath, linecount, opt)

    opt = opt or {}

    -- open file
    local file = io.open(filepath, "r", opt)
    if file then

        -- show file
        local count = 1
        for line in file:lines(opt) do

            -- show line
            io.print(line)

            -- end?
            if linecount and count >= linecount then
                break
            end

            -- update the line count
            count = count + 1
        end

        -- exit file
        file:close()
    end
end

-- tail the given file
function io.tail(filepath, linecount, opt)

    opt = opt or {}

    -- all?
    if linecount < 0 then
        return io.cat(filepath, opt)
    end

    -- open file
    local file = io.open(filepath, "r", opt)
    if file then

        -- read lines
        local lines = {}
        for line in file:lines(opt) do
            table.insert(lines, line)
        end

        -- tail lines
        local tails = {}
        if #lines ~= 0 then
            local count = 1
            for index = #lines, 1, -1 do

                -- show line
                table.insert(tails, lines[index])

                -- end?
                if linecount and count >= linecount then
                    break
                end

                -- update the line count
                count = count + 1
            end
        end

        -- show tails
        if #tails ~= 0 then
            for index = #tails, 1, -1 do

                -- show tail
                io.print(tails[index])

            end
        end

        -- exit file
        file:close()
    end
end


-- return module
return io
