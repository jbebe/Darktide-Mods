local mod = get_mod("lovesmenot")

local function update_rating(teammate)
    if mod.rating == nil then
        mod.rating = {
            version = CURRENT_VERSION,
            accounts = {}
        }
    end

    local message
    if not mod.rating.accounts[teammate.accountId] then
        -- account has not been rated yet, create object
        mod.rating.accounts[teammate.accountId] = {
            rating = RATING.AVOID
        }
        message = mod:localize("rate_notification_text_set", teammate.name, mod:localize("rating_value_avoid"))
        message = "{#color(255,20,20)}" .. SYMBOLS.SKULL .. "{#reset()} " .. message
    else
        -- account was rated, remove from table
        mod.rating.accounts[teammate.accountId] = nil
        message = mod:localize("rate_notification_text_unset", teammate.name)
        message = SYMBOLS.CHECK .. " " .. message
    end

    -- user feedback
    direct_notification(message)

    -- update team panel to show changes
end

local function rate_teammate(teammateIndex)
    if not mod.initialized or not mod.isInMission then
        return
    end

    local selected
    if teammateIndex == 1 and #mod.teammates > 0 then
        selected = mod.teammates[teammateIndex]
    elseif teammateIndex == 2 and #mod.teammates > 1 then
        selected = mod.teammates[teammateIndex]
    elseif teammateIndex == 3 and #mod.teammates > 2 then
        selected = mod.teammates[teammateIndex]
    end

    update_rating(selected)
end

function mod.rate_teammate_1() rate_teammate(1) end

function mod.rate_teammate_2() rate_teammate(2) end

function mod.rate_teammate_3() rate_teammate(3) end
