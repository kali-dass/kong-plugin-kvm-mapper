![kong-img]

Key Value Mapper Plugin
=

# Features
The KVM (Key Values Mapping) Mapper pluging provides 2 seperate features
- Admin API
  - CRUD operation for creating, reading, updating and deleting key values from the kong database
- KVM-Mapper Pluging
  - The key and respective values are added to the headers
  - Configure multiple keys in plugin

# Admin API

## What is the API endpoint
The Admin api is exposed at endpoint

```http :8001/kvm-mapper```

## Usecases it supports
- List existing keys and their values
- Create new key and value
- Read existing key and value
- Update existing key and value
- Delete existing key and value

## Example commands
### List existing keys and their values
```http :8001/kvm-mapper```
### Create new key and value
```http POST :8001/kvm-mapper key="xyz1" value="Basic TestConfiguredValue"```
### Read existing key and value
```http GET :8001/kvm-mapper/xyz1```
### Update existing key and value
```http PATCH :8001/kvm-mapper/xyz1 value="Basic TestConfiguredValuePatch"```
### Delete existing key and value
```http DELETE :8001/kvm-mapper/xyz1```

# KVM-Mapper Pluging

This plugin is configured to provide a list of keys.
The values for these keys are picked at runtime and added to the headers.

## What are the parameters
There is only one parameter for this plugin called

```kvm_keys```

## How many keys can be passed
It is possible to provide multiple keys or single key.
Atleast one key is expected to be provided.

## Mandatory config
```kvm_keys``` is mandatory field in plugin specification.
At least one value needs to be configured for plugin to work.

Plugin will return http 500 status code if parameter is missing.

## How to pass the keys
### Passing one key

```http -f :8001/services/{SOME_SERVICE}/plugins name=kvm-mapper config.kvm_keys=xyz```

### Passing Multiple keys

```http -f :8001/services/{SOME_SERVICE}/plugins name=kvm-mapper config.kvm_keys=xyz config.kvm_keys=abc```

## Key and value added to Header details
The keys and its values are added to the header as

```
"X-Kvm-Abc": "Basic TestConfiguredValueabc"
"X-Kvm-Xyz": "Basic TestingConfigxyz"
```

## What happens is the keys is not in the KVM
If the key values is not configured in KVM database, a warning message is left in the kong logs by the plugin.
But Plugin will not fault.

### For example
- If there are 3 keys
- And only 2 of these are configured via Admin API
- The 2 that are found will be added as headers
- And for the missing will be reported as warning in kong log

### Example

Plugin
- Pluging has configured the keys `abc`, `xyz` and `mno`

KVM
- KVM store has the keys `abc` and `xyz`
- KVM store does not have the key `mno`

Output
- The output headers will have `abc` and `xyz`.
- The output will NOT have the header `mno`

Kong logs will have warning

```
[warn] 68435#0: *3053 [kong] handler.lua:61 [kvm-mapper] Could not find value for kvm key : mno
```

## Is there Cache
The KVM accessed are cached locally at the kong nodes.

If the KVM gets updated via admin apis, the new values will be propogated to all nodes and cached values will be removed.

# Technical details

## Plugin execution Order - priority

The plugin priority has been set up as 999.
KVM-Mapper plugin has been given this priority of 999, so that kvm-mapper plugin runs after OIDC plugin (OIDC priority is 1000) has run.

## Encryption
The values for the keys are encrypted using keyring encryption setup when kong is configured.
If kong is not configured with key ring, then the values of the keys are not encrypted in the kong database.

For example:
If for key `abc` value is `abcConfig`.
The value `abcConfig` is stored in database in encrypted format.

## pongo
This plugin was designed to work with the
[`kong-pongo`](https://github.com/Kong/kong-pongo) and
[`kong-vagrant`](https://github.com/Kong/kong-vagrant) development environments.

# Testing using Pongo

## Pongo commands
- got to plugins directory
```
cd kong-plugin-kvm-mapper
```
- use the correct dependency by updating the file
```
.pongo/pongorc
```
- Bring up dependencies
```
pongo up
```
- expose services
```
pongo expose
```
- create kong container and attach to shell
```
pongo shell
```

## Inside Pongo Shell
- bootstrap the database
```
kong migrations bootstrap --force
```
- start kong
```
kong start
```

## Admin API Example

- Add `xyz` key and sample value
```
http POST :8001/kvm-mapper key="xyz" value="Basic xyzHasConfiguredThis"
```
- Add `abc` key and sample value
```
http POST :8001/kvm-mapper key="abc" value="Basic abcHasConfiguredThis"
```

## Sample Plugin Config Example

- Add a service to httpbin
```
http POST :8001/services name=example-service url=http://httpbin.org
```
- Add a route
```
http POST :8001/services/example-service/routes name=example-route paths:='["/echo"]'
```
- Add the plugin to service with 2 keys
```
http -f :8001/services/example-service/plugins name=kvm-mapper config.kvm_keys=xyz config.kvm_keys=abc
```
- Call the route
```
http :8000/echo/anything
```

- Output: Should look similar to below
```
{
    "args": {},
    "data": "",
    "files": {},
    "form": {},
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "Host": "httpbin.org",
        "User-Agent": "HTTPie/2.6.0",
        "X-Amzn-Trace-Id": "Root=1-61efe7fc-1430ab6c578818a52340b281",
        "X-Forwarded-Host": "kong-super-farm",
        "X-Forwarded-Path": "/echo/anything",
        "X-Forwarded-Prefix": "/echo",
        "X-Kvm-Abc": "Basic abcHasConfiguredThis",
        "X-Kvm-Xyz": "Basic xyzHasConfiguredThis"
    },
    "json": null,
    "method": "GET",
    "origin": "127.0.0.1, 86.29.209.94",
    "url": "http://kong-super-farm/anything"
}
```
NOTE: The headers are added

`"X-Kvm-Abc": "Basic abcHasConfiguredThis"`

`"X-Kvm-Xyz": "Basic xyzHasConfiguredThis"`

### Admin API update key example

- patch `xyz` key values
```
http PATCH :8001/kvm-mapper/xyz value="Basic PATCHTest"
```

- test for new values
```
http :8000/echo/anything
```

- output
```
{
    "args": {},
    "data": "",
    "files": {},
    "form": {},
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "Host": "httpbin.org",
        "User-Agent": "HTTPie/2.6.0",
        "X-Amzn-Trace-Id": "Root=1-61efea6b-466250417ccd63eb2c3cf6e5",
        "X-Forwarded-Host": "kong-super-farm",
        "X-Forwarded-Path": "/echo/anything",
        "X-Forwarded-Prefix": "/echo",
        "X-Kvm-Abc": "Basic abcHasConfiguredThis",
        "X-Kvm-Xyz": "Basic PATCHTest"
    },
    "json": null,
    "method": "GET",
    "origin": "127.0.0.1, 86.29.209.94",
    "url": "http://kong-super-farm/anything"
}
```

# Migration

## Migrate from 0.1.0 to 0.2.0
Run the below steps if you are on 0.1.0 earlier and want to migrate to 0.2.0 of the plugin after deploying the new plugin.

### Step 1: Run new migration to remove the Index

`kong migrations up`

### Step 2: Finish any Pending migration ups to remove the Index

`kong migrations finish`

[kong-img]: https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/themes/konghq/assets/img/gradient-logo.svg
