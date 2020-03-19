local typedefs = require "kong.db.schema.typedefs"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local schema = {
  name = plugin_name,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
            -- a standard defined field (typedef), with some customizations
            {
              log_level = {
                  type = "string",
                  default = "info"
              }
            },
            {
               claims = {
                   type = "map",
                   keys = {
                       type = "string",
                       match_none = {
                           {
                               pattern = "^$",
                               err = "Claim name can't be empty",
                           },
                       },
                   },
                   values = {
                       type = "string",
                       match_none = {
                           {
                               pattern = "^$",
                               err = "Claim value to validate can't be empty",
                           },
                       },
                   },
                   default = {}
               }
            },
        },
        entity_checks = {
          -- add some validation rules across fields
        },
      },
    },
  },
}

-- run_on_first typedef/field was removed in Kong 2.x
-- try to insert it, but simply ignore if it fails
pcall(function()
        table.insert(schema.fields, { run_on = typedefs.run_on_first })
      end)

return schema




--Property name         Lua type          Description
--name                  string            Name of the plugin, e.g. key-auth.
--fields                table             Array of field definitions.

--entity_checks         function         Array of conditional entity level validation checks.


--All the plugins inherit some default fields which are:
--
--Field name            Lua type         Description
--id                    string           Auto-generated plugin id.
--name                  string           Name of the plugin, e.g. key-auth.
--created_at            number           Creation time of the plugin configuration (seconds from epoch).
--route                 table            Route to which plugin is bound, if any.
--service               table            Service to which plugin is bound, if any.
--consumer              table            Consumer to which plugin is bound when possible, if any.
--protocols             table            The plugin will run on specified protocol(s).
--enabled               boolean          Whether or not the plugin is enabled.
--tags                  table            The tags for the plugin.