#!/usr/bin/env bash

#Debug
[ "$DEBUG" != "" ] && set -x

#Funcion de USO
usage () {
	echo "Usage: $0"
  exit $2
}

USERNAME=$CMK_USER
PASSWORD=$CMK_PASS
SITE=$CMK_SITE
HOST=$CMK_HOST
PROTOCOL=$CMK_PROTOCOL
API_URL="$PROTOCOL://$HOST/$SITE/check_mk/api/1.0"
#TYPE="folder_config"
#TYPE="host_tag_group"
TYPE=$1

if [ -z "$TYPE" ]; then
  echo "Debe especificar el tipo de datos a obtener desde la API."
  usage
fi

if [[ "$TYPE" == "folder_config" ]]; then
  CURL_FLAG="-G"
elif [[ "$TYPE" == "host_tag_group" ]]; then
  CURL_FLAG=""
fi

MONGODB_COLLECTION=$TYPE


# Función para obtener datos desde la API
obtener_datos_desde_api() {
    local url_api="$API_URL"
    
    echo "Obteniendo datos desde la API: $url_api"
    if [[ "$TYPE" == "folder_config" ]]; then
      local response=$(curl $CURL_FLAG -s -k\
      --request GET \
      --header "Authorization: Bearer $USERNAME $PASSWORD" \
      --header "Accept: application/json" \
      --data-urlencode 'parent=/' \
      --data-urlencode 'recursive=True' \
      --data-urlencode 'show_hosts=False' \
      "$API_URL/domain-types/$TYPE/collections/all"| jq '.value[]|select(.title)'| jq '{name: .title, title: .title, parent: .extensions.path, attributes: .extensions.attributes}'| jq 'del(.attributes.meta_data)'| jq -c '.parent = (.parent | split("/") | .[:-1] | join("/"))'|jq -c '.parent = if .parent == "" or .parent == null then "/" else .parent end') 
    elif [[ "$TYPE" == "host_tag_group" ]]; then
      local response=$(curl $CURL_FLAG -s -k\
      --request GET \
      --header "Authorization: Bearer $USERNAME $PASSWORD" \
      --header "Accept: application/json" \
      "$API_URL/domain-types/$TYPE/collections/all"| jq ".value[]"| jq -c "{ident: .title, title: .title, topic: .topic, help: .help, tags: .extensions.tags}")
    fi

    # Verificar si la solicitud fue exitosa
    local http_status=$(echo "$response" | head -n 1 | cut -d$' ' -f2)
    if [[ $? == 0 ]]; then
        echo "$response"
    else
        echo "Error al obtener los datos de la API: $http_status"
        exit 1
    fi
}

# Función para insertar datos en MongoDB
insertar_en_mongodb() {
    local datos="$1"
    local mongo_uri="$MONGODB_URI"
    local db_name="$MONGODB_DB"
    local collection_name="$MONGODB_COLLECTION"
    
    echo "Insertando datos en MongoDB: $mongo_uri, Base de datos: $db_name, Colección: $collection_name"
    
    local inserted=0
    local failed=0
    
    # Insertar datos uno por uno
    while IFS= read -r json_data; do
        #local result=$(echo "$json_data" | python -c "import sys, json; from pymongo import MongoClient; client = MongoClient('$mongo_uri'); db = client['$db_name']; collection = db['$collection_name']; try: document = json.loads(sys.stdin.read()); collection.insert_one(document); print('Documento insertado en MongoDB:', document); except Exception as e: print('Error al insertar el JSON en MongoDB:', e)")
        local result=$(echo "$json_data" | mongoimport --uri="$mongo_uri" --db="$db_name" --collection="$collection_name" --type=json 2>&1)
        if [[ $? -eq 0 ]]; then
            ((inserted++))
        else
            echo "Error al insertar el JSON en MongoDB: $result"
            ((failed++))
        fi
    done <<< "$datos"
    
    echo "Se insertaron $inserted documentos correctamente."
    echo "Fallaron $failed documentos."
}

# Función principal
main() {
    # Obtener datos desde la API
    local datos=$(obtener_datos_desde_api)
    
    # Insertar en MongoDB
    insertar_en_mongodb "$datos"
}

# Ejecutar la función principal
main

