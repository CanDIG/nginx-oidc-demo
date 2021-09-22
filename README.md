# Nginx + Keycloak Simple OIDC Demo

This is a super simple demo showing how to use Nginx and Keycloak to protect an API (here just https://httpbin.org).

For convenience, add the following lines to your `/etc/hosts`:

```
127.0.0.1       oidc
127.0.0.1       nginx
```

Then fire everything up - currently that's the OIDC IdP (Keycloak) and Nginx. Please note that we use special
Nginx docker image that has [OpenResty](https://github.com/openresty) baked in.

# Deploy all containers

```bash
docker-compose up -d
```

# Keycloak - OIDC Configuration

When keycloak is up and running (when `docker-compose logs oidc` shows `Admin console listening` - you can wait or
you can run `./oidc/wait_keycloak.sh`), add the users and realm by running 

```bash
./oidc/config-oidc-service
```

(That will take 20 seconds or so).  The keycloak will then be configured with two users (user1 and user2),
with passwords pass1 and pass2.

# Nginx - The Gateway Testing

Nginx has the Lua OpenResty plugin that allows for it to talk to OIDC server above.

```bash
curl http://nginx:8082/get

#no Authorization header found
```

```bash
TOKEN1=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )
curl -H "Authorization: Bearer ${TOKEN1}" http://nginx:8082/get

#{
#  "args": {}, 
#  "headers": {
#    "Accept": "*/*", 
#    "Authorization": "Bearer eyJhbGciOiJSUzI1NiINl[...]7Dznh4JdAA", 
#    "Host": "httpbin.org", 
#    "User-Agent": "curl/7.68.0", 
#    "X-Amzn-Trace-Id": "Root=1-614a9e8c-19d808fa10b775ce36ce4164"
#  }, 
#  "origin": "198.98.112.90", 
#  "url": "http://httpbin.org/get"
#}
```

Note a few things here:

* Nginx does not automatically do the OAuth2 dance for you; if you want that you have to use
  [OpenResty](https://github.com/openresty) and add the Lua code snippets in the nginx config.
  Please see the [default.conf](./nginx/default.conf) in this repository.
* The plugin used in Nginx is [lua-resty-openidc](https://github.com/zmartzone/lua-resty-openidc).