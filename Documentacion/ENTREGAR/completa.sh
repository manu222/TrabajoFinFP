#!/bin/bash

#Establecemos nombre de la maquina y le damos la fecha actual a la copia completa

maquina="nextcloud"
fecha=$(date +%d-%m-%Y)
nombre="${maquina}_C_${fecha}"

#Nos movemos al directorio donde se guarda la copia

cd /backups/copias/

#Hacemos la copia desde el origen hacia el lugar donde la guardaremos

rsync -avh user-copias@192.168.0.20:/var/www/html/nextcloud/data /backups/copias/"$nombre"

#Comprimimos la copia realizada

tar -czf "${nombre}.tar.gz"  "$nombre"

#Borramos el archivo sin comprimir
if [ -e /backups/copias/"${nombre}.tar.gz" ];then
rm -r "$nombre"
fi

pass=$(cat /scripts/clave)

gpg --symmetric --batch --yes --passphrase "$pass" "$nombre.tar.gz"

#borramos el archivo comprimido
if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ];then
rm -r "${nombre}.tar.gz"
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

#Borrar lo necesario

#completa anterior
fecha2=$(date --date="1 week ago" +"%d-%m-%Y")
#incremental y diferencial jueves
fecha3=$(date --date="1 day ago" +"%d-%m-%Y")


if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ] ; then
  rm -r /backups/copias/"${maquina}_C_${fecha2}.tar.gz.gpg"
fi

if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ] ; then
  rm -r /backups/copias/"${maquina}_D_${fecha3}.tar.gz.gpg"
fi

if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ] ; then
  rm -r /backups/copias/"${maquina}_I_${fecha3}.tar.gz.gpg"
fi




if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ];then
curl  -d '{"token":"q9svodrm", "message":"'"$suma"'"}' -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -v -u "bot_nxc:uD+0L=882I" https://192.168.0.20/ocs/v2.php/apps/spreed/api/v1/chat/q9svodrm
else
curl -d '{"token":"q9svodrm", "message":"'"${nombre} Ha fallado "'"}' -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -v -u "bot_nxc:C--1G++.<<<>>>IEuBBiSdaK" https://192.168.0.20/ocs/v2.php/apps/spreed/api/v1/chat/q9svodrm

fi

