This project need a file (.env) with the checkmk parammeters, for example:
```
export CMK_USER="cmk"
export CMK_PASS="cmk"
export CMK_SITE="monitoring"
export CMK_HOST="localhost"
export CMK_PROTOCOL="http"
```

and execute in cli (linux|mac):
`eval $(cat .env)`
