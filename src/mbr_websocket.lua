---
--- Websockets Server for NGINX/OpenResty
--- Created by skitsanos.
---
local server = require "resty.websocket.server"
local json = require "cjson"
local response = {
    info = function()
        return json.encode(
            {
                type = "info",
                data = {
                    version = "1.0.0",
                    id = ngx.var.request_id
                }
            }
        )
    end,
    message = function(data)
        return json.encode(
            {
                type = "message",
                data = data
            }
        )
    end
}

local m = {
    version = "1.0.0",
    debug = true,
    json = true,
    send = nil,
    on = {
        message = nil
    }
}

function m.log(...)
    if (m.debug) then
        ngx.log(...)
    end
end

function m.run()
    local wb, err =
        server:new {
        max_payload_len = 32768,
        timeout = 5000
    }

    if not wb then
        m.log(ngx.ERR, "failed to new websocket: ", err)
        return ngx.exit(444)
    end

    wb:send_text(response.info())

    m.send = function(data)
        wb:send_text(data)
    end

    while true do
        -- try to receive
        local data, typ, errReceive = wb:recv_frame()

        -- check socked timeout
        if not data then
            if not string.find(errReceive, "timeout", 1, true) then
                m.log(ngx.ERR, "failed to receive a frame: ", errReceive)
                return ngx.exit(444)
            end
        end

        local token = ngx.var.arg_token
        if (token == nil) then
            token = ngx.var.request_id
        end

        if (typ ~= nil) then
            m.log(ngx.INFO, "received a frame of type ", typ, " and payload ", data)
        end

        local switch = {
            ["close"] = function()
                -- for typ "close", err contains the status code
                local code = errReceive

                -- send a close frame back:
                local bytes, errSendClose = wb:send_close(1000)
                if (not bytes) then
                    m.log(ngx.ERR, "failed to send the close frame: ", errSendClose)
                end

                m.log(ngx.INFO, "closing with status code ", code, " and message ", data)
                return 1, errSendClose
            end,
            ["ping"] = function()
                local bytes, SendPong = wb:send_pong()
                if (not bytes) then
                    ngx.log(ngx.ERR, "failed to send frame: ", SendPong)
                    return 1, SendPong
                end
            end,
            ["text"] = function()
                if (not m.json) then
                    if (m.on.message ~= nil) then
                        m.on.message(data, m.send)
                    end

                    return 0, nil
                end

                -- decode payload
                local ok, payload = pcall(json.decode, data)
                if (ok ~= true) then
                    wb:send_close(1003, "Incorrect payload format. Must be valid JSON")
                    return 1, ok
                end

                if (m.on.message ~= nil) then
                    m.on.message(payload, m.send)
                end

                return 0, nil
            end
        }

        if (typ == "close") then
            break
        end

        if (typ ~= nil) then
            -- check for return code
            local _, errRet = switch[typ]()
            if (errRet) then
                break
            end
        end
    end

    wb:send_close()
end

return m
