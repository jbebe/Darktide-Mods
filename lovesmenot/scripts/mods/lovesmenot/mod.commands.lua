local mod = get_mod("lovesmenot")
local json = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/thirdparty/json")

mod:command("lmn_cmd", "(lovesmenot) Get property on local player object", function(modProperty, subProperty)
    local value = mod[modProperty]
    if subProperty then
        value = value[subProperty]
    end

    mod:echo(json.encode(value))
end)

mod:command("lmn_save", "(lovesmenot) Save state to file", function()
    mod:persist_rating()
end)
