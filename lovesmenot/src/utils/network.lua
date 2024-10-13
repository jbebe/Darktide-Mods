local constants = modRequire 'lovesmenot/src/constants'

local utils = {}

---@param accessToken string
---@return Promise
function utils.getRatingsAsync(accessToken)
    if not Managers.backend:authenticated() then
        ---@cast Promise Promise
        return Promise.resolved(nil)
    end

    local url = ('%s/ratings'):format(constants.API_PREFIX)
    local promise = Managers.backend:url_request(url, {
        -- 'false' removes the Dartkide jwt token from Authorization header
        require_auth = false,
        method = 'GET',
        headers = {
            Authorization = 'Bearer ' .. accessToken,
        }
    }):next(function(response) return response.body end)
    return promise
end

---@class TargetRequest
---@field type RATINGS
---@field characterLevel number

---@class RatingRequest
---@field characterLevel number
---@field reef string
---@field updates? table<string, TargetRequest>
---@field deletes? string[]
---@field friends string[]

---@param accessToken string
---@param request RatingRequest
---@return Promise
function utils.updateRatingsAsync(accessToken, request)
    if not Managers.backend:authenticated() then
        ---@cast Promise Promise
        return Promise.resolved(nil)
    end

    local url = ('%s/ratings'):format(constants.API_PREFIX)
    local promise = Managers.backend:url_request(url, {
        -- 'false' removes the Dartkide jwt token from Authorization header
        require_auth = false,
        method = 'POST',
        headers = {
            Authorization = 'Bearer ' .. accessToken,
        },
        body = request,
    })
    return promise
end

return utils
