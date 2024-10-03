#!/bin/bash

#variables de fecha para borrar
fecha2=$(date --date="yesterday")
#incremental y diferencial jueves
fecha3=$(date --date="2 day ago")

#Establecemos nombre de la maquina y le damos la fecha actual a la copia diferencial

maquina="nextcloud"
fecha=$(date +%d-%m-%Y)
nombre="${maquina}_I_${fecha}"

#archivos a comparar

viernespasado="${maquina}_C_$(date --date="last friday" +"%d-%m-%Y")"
diferencialhoy="${maquina}_D_$(date --date="today" +"%d-%m-%Y")"
diferencialsabado="${maquina}_D_$(date --date="last saturday" +"%d-%m-%Y")"

#Ver el dia
vardia=$(date --date="today" +"%a")

#Nos movemos al directorio donde se guarda la copia

cd /backups/copias/

#Hacemos la copia desde el origen hacia el lugar donde la guardaremos

pass=$(cat /scripts/clave)

if [ "$vardia" = "dom" ];then

gpg --batch --yes --passphrase "$pass" -o "${viernespasado}.tar.gz" -d "${viernespasado}.tar.gz.gpg"

tar xvf /backups/copias/"${viernespasado}.tar.gz"

gpg --batch --yes --passphrase "$pass" -o "${diferencialsabado}.tar.gz" -d "${diferencialsabado}.tar.gz.gpg"

tar xvf /backups/copias/"${diferencialsabado}.tar.gz"

#borramos el archivo comprimido
if [ -e "${viernespasado}.tar.gz" ] && [ -e "${diferencialsabado}.tar.gz" ];then
rm -r "${viernespasado}.tar.gz" "${diferencialsabado}.tar.gz"
fi
#comprobamos los archivos de la complera con la diferencial
rsync -avh --compare-dest=/backups/copias/"$viernespasado" --compare-dest=/backups/copias/"$diferencialsabado"   user-copias@192.168.0.20:/var/www/html/nextcloud/data /backups/copias/"$nombre"

#borramos los archivos del viernes y del sabado descomprimidos
if [ -e "$viernespasado" ] && [ -e  "$diferencialsabado" ];then
rm -r "$viernespasado" "$diferencialsabado"
fi

#Comprimimos la copia realizada

tar -czf "${nombre}.tar.gz"  "$nombre"

#Borramos el archivo sin comprimir
if [ -e "$nombre" ];then
rm -r "$nombre"
fi

#ciframos la copia incremental
gpg --symmetric --batch --yes --passphrase "$pass" "${nombre}.tar.gz"

if [ -e  "${nombre}.tar.gz" ]; then
rm -r  "${nombre}.tar.gz"
fi

#Suma de comprobacion del archivo cifrado con SHA-1

suma=$(sudo sha1sum "${nombre}.tar.gz.gpg")

if [ -e /backups/copias/SHA-1_sums.txt ];then
        echo "ARCHIVO EXISTE"
echo "$suma" >> /backups/copias/SHA-1_sums.txt
else
touch /backups/copias/SHA-1_sums.txt
echo "$suma" >> /backups/copias/SHA-1_sums.txt
fi

fi

if [ "$vardia" != "vie" ] && [ "$vardia" != "sab" ] && [ "$vardia" != "dom" ];then

gpg --batch --yes --passphrase "$pass" -o "${viernespasado}.tar.gz" -d "${viernespasado}.tar.gz.gpg"

tar xvf /backups/copias/"${viernespasado}.tar.gz"

gpg --batch --yes --passphrase "$pass" -o "${diferencialhoy}.tar.gz" -d "${diferencialhoy}.tar.gz.gpg"

tar xvf /backups/copias/"${diferencialhoy}.tar.gz"

#borramos el archivo comprimido

if [ -e "${viernespasado}.tar.gz" ] && [ -e "${diferencialhoy}.tar.gz" ];then
rm -r "${viernespasado}.tar.gz"
rm -r "${diferencialhoy}.tar.gz"
fi

#Comprobamos con la copia completa y con la diferencial
rsync -avh --compare-dest=/backups/copias/"$viernespasado" --compare-dest=/backups/copias/"$diferencialhoy"   user-copias@192.168.0.20:/var/www/html/nextcloud/data /backups/copias/"$nombre"

#borramos los archivos descomprimidos de la completa y la diferencial
if [ -e "$viernespasado" ] && [ -e  "$diferencialhoy" ]; then
rm -r "$viernespasado" "$diferencialhoy"
fi


#Comprimimos la copia realizada

tar -czf "${nombre}.tar.gz"  "$nombre"

#Borramos el archivo sin comprimir

if [ -e "$nombre" ]; then
rm -r "$nombre"
fi
#Ciframos la copia incremental cifrada
gpg --symmetric --batch --yes --passphrase "$pass" "${nombre}.tar.gz"

#borramos el tar.gz
if [ -e  "${nombre}.tar.gz" ]; then
rm -r  "${nombre}.tar.gz"
fi

#Suma de comprobacion del archivo cifrado con SHA-1
suma=$(sudo sha1sum "${nombre}.tar.gz.gpg")

if [ -e /backups/copias/SHA-1_sums.txt ];then
        echo "ARCHIVO EXISTE"
echo "$suma" >> /backups/copias/SHA-1_sums.txt
else
touch /backups/copias/SHA-1_sums.txt
echo "$suma" >> /backups/copias/SHA-1_sums.txt
fi

fi



if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ];then
curl -d '{"token":"q9svodrm", "message":"'"$suma"'"}' -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -v -u "bot_nxc:uD+0L=882I" https://192.168.0.20/ocs/v2.php/apps/spreed/api/v1/chat/q9svodrm
else
curl -d '{"token":"q9svodrm", "message":"'"$nombre"' HA FALLADO"}' -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -v -u "bot_nxc:uD+0L=882I" https://192.168.0.20/ocs/v2.php/apps/spreed/api/v1/chat/q9svodrm

fi
