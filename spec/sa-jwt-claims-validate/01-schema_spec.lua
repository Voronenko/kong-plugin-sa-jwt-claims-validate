local PLUGIN_NAME = "sa-jwt-claims-validate"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

  it("accepts configuration", function()
    local ok, err = validate({
        claims={
          username = "slavko",
          id = "1212"
        }
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

end)
