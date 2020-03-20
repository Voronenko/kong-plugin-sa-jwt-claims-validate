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
                option_expose_headers = {
                    type = "boolean",
                    default = true
                }
            },
            {
                exposed_headers = {
                    type = "string",
                    default = "all"
                }
            },

            --The "iss" (issuer) claim identifies the principal that issued the
            --JWT.  The processing of this claim is generally application specific.
            --The "iss" value is a case-sensitive string containing a StringOrURI
            --value.  Use of this claim is OPTIONAL.

            {
                validate_iss = {
                    type = "string",
                }
            },

--            The "sub" (subject) claim identifies the principal that is the
--            subject of the JWT.  The claims in a JWT are normally statements
--about the subject.  The subject value MUST either be scoped to be
--locally unique in the context of the issuer or be globally unique.
--The processing of this claim is generally application specific.  The
--"sub" value is a case-sensitive string containing a StringOrURI
--value.  Use of this claim is OPTIONAL.

            {
                validate_sub = {
                    type = "string",
                }
            },

--            The "aud" (audience) claim identifies the recipients that the JWT is
--            intended for.  Each principal intended to process the JWT MUST
--identify itself with a value in the audience claim.  If the principal
--processing the claim does not identify itself with a value in the
--"aud" claim when this claim is present, then the JWT MUST be
--rejected.  In the general case, the "aud" value is an array of case-
--sensitive strings, each containing a StringOrURI value.  In the
--special case when the JWT has one audience, the "aud" value MAY be a
--single case-sensitive string containing a StringOrURI value.  The
--interpretation of audience values is generally application specific.
--Use of this claim is OPTIONAL.

            {
                validate_aud = {
                    type = "string",
                }
            },

            {
                validate_azp = {
                    type = "string",
                }
            },

            {
                validate_client_id = {
                    type = "string",
                }
            },

            {
                validate_dynamic1 = {
                         type = "string",
                }
            },

            {
                validate_dynamic2 = {
                         type = "string",
                }
            },
            {
                validate_dynamic3 = {
                         type = "string",
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