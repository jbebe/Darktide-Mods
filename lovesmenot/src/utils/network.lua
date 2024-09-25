local DMF = get_mod('DMF')
local json = modRequire 'lovesmenot/nurgle_modules/json'
local constants = modRequire 'lovesmenot/src/constants'

local utils = {}

local function handleNetworkError(errorObject)
    local errorMessage = type(errorObject) == 'table' and table.tostring(errorObject, 3) or errorObject
    DMF:error('Failed to download ratings with error: ' .. errorMessage)
end

---@class RatingResponse
---@field type string
---@field hash string

---@class Promise<T, T2>: { next: fun(self: any, callback: fun(input: T): T2 | nil): Promise<T2 | nil> }

---@return Promise<RemoteRating> | nil
function utils.getRatings()
    if not Managers.backend:authenticated() then
        DMF:error('Cannot initiate api call if not authenticated to game backend')
    else
        local url = ('%s/ratings'):format(constants.API_PREFIX)
        local promise = Managers.backend:url_request(url, {
            method = 'GET',
            require_auth = true, -- this must be true always
        }):next(
            function(response)
                return response.body
            end,
            handleNetworkError
        )
        return promise
    end
end

---@class TargetRequest
---@field type RATINGS
---@field targetXp number

---@class RatingRequest
---@field sourceHash string
---@field sourceXp number
---@field sourceReef string
---@field targets table<string, TargetRequest>

---@param request RatingRequest
---@return Promise<nil> | nil
function utils.updateRatings(request)
    if not Managers.backend:authenticated() then
        DMF:error('Cannot initiate api call if not authenticated to game backend')
    else
        local url = ('%s/ratings'):format(constants.API_PREFIX)
        local promise = Managers.backend:url_request(url, {
            method = 'POST',
            require_auth = true, -- this must be true always
            body = request,
        }):next(
            function() --[[ NO OP ]] end,
            handleNetworkError
        )
        return promise
    end
end

return utils
