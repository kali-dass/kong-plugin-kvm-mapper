local helpers = require "spec.helpers"
local PLUGIN_NAME = "kvm-mapper"


for _, strategy in helpers.all_strategies() do
    describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
      local client
  
      lazy_setup(function()
  
        local bp, db = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })
  
        -- Inject a test service and route. No need to create a service, there is a default
        -- service which will echo the request.
        local service = bp.services:insert({
          path = "/request"
        })
  
        bp.routes:insert({
          hosts = { "test1.com" },
          service = { id = service.id }
        })
  
        -- add the plugin to test to the service we created
        bp.plugins:insert {
          name = PLUGIN_NAME,
          config = {
          },
        }
  
        db.kvm_mappings:insert {
            key = "xyz",
            value = "Basic TestConfiguredValue",
        }
  
        -- start kong
        assert(helpers.start_kong({
          -- set the strategy
          database   = strategy,
          -- use the custom test template to create a local mock server
          nginx_conf = "spec/fixtures/custom_nginx.template",
          -- make sure our plugin gets loaded
          plugins = "bundled," .. PLUGIN_NAME,
          -- write & load declarative config, only if 'strategy=off'
          declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
        }))
      end)
  
      lazy_teardown(function()
        helpers.stop_kong(nil, true)
      end)
  
      before_each(function()
        client = helpers.proxy_client()
      end)
  
      after_each(function()
        if client then client:close() end
      end)
  
  
  
      describe("request", function()
 
      end)
  
    end)
  end