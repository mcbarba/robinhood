#!/usr/bin/env bash

#Debug
[ "$DEBUG" != "" ] && set -x

#Funcion de USO
usage () {
	echo "Usage: $0"
  exit $2
}

USERNAME=$CMK_USER_DST
PASSWORD=$CMK_PASS_DST
SITE=$CMK_SITE_DST
HOST=$CMK_HOST_DST
PROTOCOL=$CMK_PROTOCOL_DST
API_URL="$PROTOCOL://$HOST/$SITE/check_mk/api/1.0"
TYPE="folder_config"


# Función para realizar una solicitud POST a la API ficticia
realizar_solicitud_post() {
    local url_api="$API_URL"
    local registro="$1"

    echo "Realizando solicitud POST a la API ficticia: $url_api"

    #local response=$(curl -s -X POST --header "Authorization: Bearer $USERNAME $PASSWORD" \
    #--header "Accept: application/json" \
    #--header "Content-Type: application/json" \ -d "$registro" "$url_api")

    # Verificar si la solicitud fue exitosa
    if [[ $? -eq 0 ]]; then
        echo "Solicitud POST exitosa: $response"
    else
        echo "Error al realizar la solicitud POST a la API: $http_status"
    fi
}

# Función principal
main() {
    # Conexión a MongoDB
    local mongo_uri="$MONGODB_URI"
    local db_name="$MONGODB_DB"
    local collection_name="$MONGODB_COLLECTION"

    echo "Conectando a MongoDB: $mongo_uri, Base de datos: $db_name, Colección: $collection_name"

    # Obtener registros de la colección en MongoDB
    local registros=$(mongo "$mongo_uri" --quiet --eval "var cursor = db.getSiblingDB('$db_name').$collection_name.find(); while (cursor.hasNext()) { printjson(cursor.next()) }")

    # Recorrer cada registro y realizar la solicitud POST
    while IFS= read -r registro; do
        realizar_solicitud_post "$registro"
    done <<< "$registros"
}

# Ejecutar la función principal
main

