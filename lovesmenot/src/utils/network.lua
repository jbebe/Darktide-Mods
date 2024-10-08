local DMF = get_mod('DMF')
local constants = modRequire 'lovesmenot/src/constants'

local utils = {}

local function handleNetworkError(errorObject)
    local errorMessage = type(errorObject) == 'table' and table.tostring(errorObject, 3) or errorObject
    DMF:error('Failed to download ratings with error: ' .. errorMessage)
end

---@class Promise<T>: { next: fun(self: Promise<T>, callback: fun(input: T): any): Promise<T>, catch: fun(self: Promise<T>, callback: fun(error: any)): Promise<T> }

---@param accessToken string
---@return Promise<CommunityRating> | nil
function utils.getRatings(accessToken)
    if not Managers.backend:authenticated() then
        DMF:error('Cannot initiate api call if not authenticated to game backend')
        return
    end
    local url = ('%s/ratings'):format(constants.API_PREFIX)
    local promise = Managers.backend:url_request(url, {
        require_auth = false, -- this must be true always
        method = 'GET',
        headers = {
            Authorization = 'Bearer ' .. accessToken,
        }
    }):next(
        function(response)
            return response.body
        end
    )
    return promise
end

---@class TargetRequest
---@field type RATINGS
---@field targetLevel number

---@class RatingRequest
---@field sourceHash string
---@field sourceLevel number
---@field sourceReef string
---@field targets table<string, TargetRequest>

---@param accessToken string
---@param request RatingRequest
---@return Promise<nil> | nil
function utils.updateRatings(accessToken, request)
    if not Managers.backend:authenticated() then
        DMF:error('Cannot initiate api call if not authenticated to game backend')
        return
    end
    local url = ('%s/ratings'):format(constants.API_PREFIX)
    local promise = Managers.backend:url_request(url, {
        require_auth = false, -- this must be true always
        method = 'POST',
        headers = {
            Authorization = 'Bearer ' .. accessToken,
        },
        body = request,
    }):next(
        function() --[[ NO OP ]] end,
        handleNetworkError
    )
    return promise
end

return utils
