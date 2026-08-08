local function classic(parent, offset)
    local target = parent.files[parent.cursor + 1 + offset]
    if target and target.cha.is_dir then
        ya.emit("cd", { target.url })
    end
end

local function skipFiles(parent, offset)
    local start = parent.cursor + 1 + offset
    local end_ = offset < 0 and 1 or #parent.files
    local step = offset < 0 and -1 or 1
    for i = start, end_, step do
        local target = parent.files[i]
        if target and target.cha.is_dir then
            return ya.emit("cd", { target.url })
        end
    end
end

--- @sync entry
local function entry(_, job)
    local parent = cx.active.parent
    if not parent then return end

    local mode = job.args[1]
    if not mode then return ya.err('Missing mode argument: "classic" or "skip-files"') end

    local offset = tonumber(job.args[2])
    if not offset then return ya.err(job.args[2], 'is not a number') end


    local modes = {
        ["classic"] = classic,
        ["skip-files"]  = skipFiles,
    }

    if modes[mode] then
        modes[mode](parent, offset)
    else
        ya.err('Invalid mode: ' .. mode .. '. Use "classic" or "skip-files"')
    end

end

return { entry = entry }
