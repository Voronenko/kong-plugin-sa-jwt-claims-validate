local helpers = require "spec.helpers"
local PLUGIN_NAME = "sa-jwt-claims-validate"

-- luacheck: ignore
function debug_dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. debug_dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end


for _, strategy in helpers.each_strategy() do
    describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
        local client

        lazy_setup(function()

            local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

            -- Inject a test route. No need to create a service, there is a default
            -- service which will echo the request.
            local route1 = bp.routes:insert({
                hosts = { "test1.com" },
            })
            -- add the plugin to test to the route we created
            bp.plugins:insert {
                name = PLUGIN_NAME,
                route = { id = route1.id },
                config = {
                    validate_azp = "R477zd0dhD0Hq3CnNIEgE677nwboYD5u",
                },
            }

            -- start kong
            assert(helpers.start_kong({
                -- set the strategy
                database   = strategy,
                -- use the custom test template to create a local mock server
                nginx_conf = "spec/fixtures/custom_nginx.template",
                -- make sure our plugin gets loaded
                plugins = "bundled," .. PLUGIN_NAME,
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

            --it("dumps headers so I can visually see smth in travisci", function()
            --    local r = client:get("/request", {
            --        headers = {
            --            host = "test1.com",
            --            Authorization = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlF6bEZOak5CUmtZNVJqY3lOVVpCUmpJMU5qRkJOMFl4T0VNMVJFSXhNelU0TVVJeU5qa3dSUSJ9.eyJpc3MiOiJodHRwczovL3Zvcm9uZW5rby5hdXRoMC5jb20vIiwic3ViIjoiUjQ3N3pkMGRoRDBIcTNDbk5JRWdFNjc3bndib1lENXVAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vaW1wbGljaXRncmFudC5hdXRoMC52b3JvbmVua28ubmV0IiwiaWF0IjoxNTc1NTgzNTM2LCJleHAiOjE1NzU2Njk5MzYsImF6cCI6IlI0Nzd6ZDBkaEQwSHEzQ25OSUVnRTY3N253Ym9ZRDV1IiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.aIx7LnT7aFPxmK4wCXxxGhEKrxPsGlZ3azEFykynkf6hfyb-4zCXlrqvxNjB9pk_PO8MxmKRJeoRsHLmNOvVls3tE90GQNa6DrqyWuO5PxZetkPyR56o5axt4PddZlop-mukiMYrZF2bP_gdRBZnhR2OJ4vU3qG6Rvs2k-J65tbb2oUERWps7KDC2FeTbV2bc09JtH25StNfYyHOPUR1MiDSKZbZqH3Z0bZUFHN1Ac7jznU3xUV8yEPTy7hQwOWUK5CxUSvd_s4RlTLKsHdAQWWxoDPRvxldwPXtxc7n13hwQPslJNR1ScbREcgJo4zPOcVM_uzTk1ygczLJCzvdsA"
            --        }
            --    })
            --    -- validate the value of that header
            --    assert.response(r).has.status(200)
            --    print("Headers:", debug_dump(assert.response(r)))
            --end)

            it("Proper jwt token passes through", function()
                local r = client:get("/request", {
                    headers = {
                        host = "test1.com",
                        Authorization = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlF6bEZOak5CUmtZNVJqY3lOVVpCUmpJMU5qRkJOMFl4T0VNMVJFSXhNelU0TVVJeU5qa3dSUSJ9.eyJpc3MiOiJodHRwczovL3Zvcm9uZW5rby5hdXRoMC5jb20vIiwic3ViIjoiUjQ3N3pkMGRoRDBIcTNDbk5JRWdFNjc3bndib1lENXVAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vaW1wbGljaXRncmFudC5hdXRoMC52b3JvbmVua28ubmV0IiwiaWF0IjoxNTc1NTgzNTM2LCJleHAiOjE1NzU2Njk5MzYsImF6cCI6IlI0Nzd6ZDBkaEQwSHEzQ25OSUVnRTY3N253Ym9ZRDV1IiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.aIx7LnT7aFPxmK4wCXxxGhEKrxPsGlZ3azEFykynkf6hfyb-4zCXlrqvxNjB9pk_PO8MxmKRJeoRsHLmNOvVls3tE90GQNa6DrqyWuO5PxZetkPyR56o5axt4PddZlop-mukiMYrZF2bP_gdRBZnhR2OJ4vU3qG6Rvs2k-J65tbb2oUERWps7KDC2FeTbV2bc09JtH25StNfYyHOPUR1MiDSKZbZqH3Z0bZUFHN1Ac7jznU3xUV8yEPTy7hQwOWUK5CxUSvd_s4RlTLKsHdAQWWxoDPRvxldwPXtxc7n13hwQPslJNR1ScbREcgJo4zPOcVM_uzTk1ygczLJCzvdsA"
                    }
                })
                -- validate that the request succeeded, response status 200
                assert.response(r).has.status(200)
                -- now check the request (as echoed by mockbin) to have the header
            end)

            --http://jwtbuilder.jamiekurtz.com/
            it("Improper jwt token rejected", function()
                local r = client:get("/request", {
                    headers = {
                        host = "test1.com",
                        Authorization = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE1ODQ2MTg0MzcsImV4cCI6MTYxNjE1NDQzNywiYXVkIjoid3d3LmV4YW1wbGUuY29tIiwic3ViIjoianJvY2tldEBleGFtcGxlLmNvbSIsIkdpdmVuTmFtZSI6IkpvaG5ueSIsIlN1cm5hbWUiOiJSb2NrZXQiLCJFbWFpbCI6Impyb2NrZXRAZXhhbXBsZS5jb20iLCJSb2xlIjpbIk1hbmFnZXIiLCJQcm9qZWN0IEFkbWluaXN0cmF0b3IiXX0.oD9SNXOUkcyt9_-ljEtI56MaZudA_W9YypQy9c3IHmzwABEvJOmUUu0Nbhvmv1yta87jUAI4YGOJFgN0wockHQ"
                    }
                })
                -- validate that the request succeeded, response status 200
                assert.response(r).has.status(401)
                -- now check the request (as echoed by mockbin) to have the header
            end)


        end)

    end)
end
