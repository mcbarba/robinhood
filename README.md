This project need a file (.env) with the checkmk parammeters, for example:
```
export CMK_USER="cmk"
export CMK_PASS="cmk"
export CMK_SITE="monitoring"
export CMK_HOST="localhost"
export CMK_PROTOCOL="http"
export CMK_URL=${CMK_PROTOCOL}://${CMK_HOST}/${CMK_SITE}
export CMK_USER_DST="cmkadmin"
export CMK_PASS_DST="cmkadmin"
export CMK_SITE_DST="monitoring"
export CMK_HOST_DST="localhost:8080"
export CMK_PROTOCOL_DST="http"
export CMK_URL_DST=${CMK_PROTOCOL_DST}://${CMK_HOST_DST}/${CMK_SITE_DST}
export MONGODB_URI="mongodb://localhost:27017"
export MONGODB_DB="checkmk"
export MONGODB_COLLECTION="folder_config"

```

and execute in cli (linux|mac):
`eval $(cat .env)`
