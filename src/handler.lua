local BasePlugin = require "kong.plugins.base_plugin"
local http = require "resty.http"

local ExternalAuthHandler = BasePlugin:extend()

ExternalAuthHandler.PRIORITY = 1999

function ExternalAuthHandler:new()
    ExternalAuthHandler.super.new(self, "request-intercept")
end

function ExternalAuthHandler:access(conf)
    ExternalAuthHandler.super.access(self)

    local client = http.new()
    client:set_timeouts(conf.connect_timeout, send_timeout, read_timeout)

    local res, err = client:request_uri(conf.url, {
        method = kong.request.get_method(),
        headers = kong.request.get_headers()

    })

    if not res then
        kong.response.exit(500, { message = err })
    end
    if res.status ~= 200 then
        kong.response.exit(401, { message = "Invalid authentication credentials" })
    end

    client:close()

end

return ExternalAuthHandler