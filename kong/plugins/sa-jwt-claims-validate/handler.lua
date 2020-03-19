-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------

----PLUGIN VARS------------------------------------------------------------------------------
-- luacheck: ignore
local parsedToken = nil
-- luacheck: ignore
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local ngx_re_gmatch = ngx.re.gmatch


--------JWT Parsing logic--------------------------------------------------------------------

local function retrieve_token(request, conf)
  local authorization_header = request.get_headers()["authorization"]
  if authorization_header then
    local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      return nil, iter_err
    end
    local m, err = iterator()
    if err then
      return nil, err
    end
    if m and #m > 0 then
      return m[1]
    end
  end
end

--------/JWT Parsing logic-------------------------------------------------------------------

----PLUGIN DEF-------------------------------------------------------------------------------

--- This plugin might rely on jwt plugin result
--- makes sense to fire it after jwt which is 1005
---

local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1",
}



-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



---[[ handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
-- Executed upon every Nginx worker process’s startup.
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]



--[[ runs in the ssl_certificate_by_lua_block handler
-- 	Executed during the SSL certificate serving phase of the SSL handshake.
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!

-- Executed for every request upon its reception from a client as a rewrite phase handler.
-- NOTE in this phase neither the Service nor the Consumer have been identified, hence this handler
-- will only be executed if the plugin was configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]



---[[ runs in the 'access_by_lua_block'
--- Executed for every request from a client and before it is being proxied to the upstream service.
function plugin:access(plugin_conf)
  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  ngx.req.set_header(plugin_conf.request_header, "this is on a request")
  local token, err = retrieve_token(ngx.req, plugin_conf)
  if err then
    -- TODO: provide response
  end

  if token then
    ngx.req.set_header("x-sa-jwt-token", token)

    local jwt, err = jwt_decoder:new(token)
    if err then
      -- TODO: provide response
    end
    local claims = jwt.claims
    for k,v in pairs(claims) do
      ngx.req.set_header("x-sa-jwt-claim-" .. k, v)
    end
  end

end --]]


---[[ runs in the 'header_filter_by_lua_block'
--- Executed when all response headers bytes have been received from the upstream service.
function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  ngx.header[plugin_conf.response_header] = "this is on the response"

end --]]


--[[ runs in the 'body_filter_by_lua_block'
-- Executed for each chunk of the response body received from the upstream service.
Since the response is streamed back to the client, it can exceed the buffer size and be streamed
chunk by chunk. hence this method can be called multiple times if the response is large.
See the lua-nginx-module documentation for more details.
function plugin:body_filter(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'body_filter' handler")

end --]]


--[[ runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")

end --]]


-- return our plugin object
return plugin
