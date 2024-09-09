local utils = {}

function utils.colorize(color, text)
    return '{#color(' .. color .. ')}' .. text .. '{#reset()}'
end

return utils
