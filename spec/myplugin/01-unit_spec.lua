local PLUGIN_NAME = "kvm-mapper"

-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end

describe(PLUGIN_NAME .. ": (schema)", function()
  -- check one value in kvm
  it("kvm_keys takes One value", function ()
    -- call validate with one key
    local ok, err = validate({ kvm_keys = {"abc"}})
    -- no error
    assert.is_nil(err)
    -- is not nil or not false response
    assert.is_truthy(ok)
  end)

  it("kvm_keys takes Multiple values", function ()
    -- call validate with two key
    local ok, err = validate({ kvm_keys = {"abc","xyz"}})
    -- no error
    assert.is_nil(err)
    -- is not nil or not false response
    assert.is_truthy(ok)
  end)

  it("Mandatory field kvm_keys", function ()
    -- call validate with no key
    local ok, err = validate({})
    -- has error
    assert.is_not_nil(err)
    -- is nil or false response
    assert.is_falsy(ok)
  end)
end)
