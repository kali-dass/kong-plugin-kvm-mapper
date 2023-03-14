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

## NOTE: For working version of KVM mapper plugin use branch or tag v0.2.0 that works for service/route/consumer etc

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
This plugin need to be added in the config file and not added via the Gateway.

## What are the parameters
There is no parameter for this plugin

## How many keys can be passed
It is possible to provide multiple keys or single key.
Atleast one key is expected to be provided.

## How to pass the keys
### Passing one key

```http -f :8001/services/{SOME_SERVICE}/plugins name=kvm-mapper config.kvm_keys=xyz```

### Passing Multiple keys

```http -f :8001/services/{SOME_SERVICE}/plugins name=kvm-mapper config.kvm_keys=xyz config.kvm_keys=abc```

### For example
- If there are 3 keys
- And only 2 of these are configured via Admin API
- The 2 that are found will be added as headers
- And for the missing will be reported as warning in kong log

### Example

Plugin can be called from other plugin by using following code

```kong.db.kvm_mappings:select_by_key(key)```

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

**Remember to delete the pongo container by running!**
```
pongo down
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

# Migration

## Migrate from 0.1.0 to 0.2.0
Run the below steps if you are on 0.1.0 earlier and want to migrate to 0.2.0 of the plugin after deploying the new plugin.

### Step 1: Run new migration to remove the Index

`kong migrations up`

### Step 2: Finish any Pending migration ups to remove the Index

`kong migrations finish`

[kong-img]: https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/themes/konghq/assets/img/gradient-logo.svg
