#!/bin/bash

#variables de fecha para borrar
#Un dia antes
fecha2=$(date --date="yesterday")
#dos dias antesgua
fecha3=$(date --date="2 day ago")

#Establecemos nombre de la maquina y le damos la fecha actual a la copia diferencial

maquina="nextcloud"
fecha=$(date +%d-%m-%Y)
nombre="${maquina}_D_${fecha}"

#completa semana pasada

viernespasado="${maquina}_C_$(date --date="last friday" +"%d-%m-%Y")"
viernesactual="${maquina}_C_$(date --date="today" +"%d-%m-%Y")"

vardia=$(date --date="today" +"%a")

#Nos movemos al directorio donde se guarda la copia

cd /backups/copias/

#Hacemos la copia desde el origen hacia el lugar donde la guardaremos

pass=$(cat /scripts/clave)

if [ "$vardia" = "vie" ]; then

gpg --batch --yes --passphrase "$pass" -o "${viernesactual}.tar.gz" -d "${viernesactual}.tar.gz.gpg"

tar xvf /backups/copias/"${viernesactual}.tar.gz"

#borramos el archivo comprimido
if [ -e "${viernesactual}" ]; then
rm -r "${viernesactual}.tar.gz"
fi
#comparamos la completa con los datos 

rsync -avh --compare-dest=/backups/copias/"$viernesactual"  user-copias@192.168.0.20:/var/www/html/nextcloud/data /backups/copias/"$nombre"

#Borramos la completa descomprimida
if [ -e "$nombre" ]; then
rm -r "$viernesactual"
fi
#Comprimimos la copia realizada

tar -czf "${nombre}.tar.gz"  "$nombre"

#Borramos el archivo sin comprimir

rm -r "$nombre"

#encriptamos el archivo comprimido
gpg --symmetric --batch --yes --passphrase "$pass" "${nombre}.tar.gz"

#borramos el archvio diferencial .tar.gz para quedarnos solo con *.tar.gz.gpg
if [ -e  "${nombre}.tar.gz.gpg" ]; then
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

if [ "$vardia" = "lun" ]; then

#desencriptamos la copia completa
gpg --batch --yes --passphrase "$pass" -o "${viernespasado}.tar.gz" -d "${viernespasado}.tar.gz.gpg"

#descomprimimos
tar xvf /backups/copias/"${viernespasado}.tar.gz"

#borramos el archivo comprimido
if [ -e "${viernespasado}" ]; then
rm -r "${viernespasado}.tar.gz"
fi

# cpmparamos la completa con el original 
rsync -avh --compare-dest=/backups/copias/"$viernespasado"  user-copias@192.168.0.20:/var/www/html/nextcloud/data /backups/copias/"$nombre"

#borramos la ccompleta sin comprimir
if [ -e "$viernespasado" ]; then
rm -r "$viernespasado"
fi

#Comprimimos la copia realizada

tar -czf "${nombre}.tar.gz"  "$nombre"

#Borramos el archivo sin comprimir
if [ -e "${nombre}.tar.gz" ]; then
rm -r "$nombre"
fi

#encriptamos la copia diferencial comprimida
gpg --symmetric --batch --yes --passphrase "$pass" "${nombre}.tar.gz"

#borramos el archvio diferencial .tar.gz para quedarnos solo con *.tar.gz.gpg
if [ -e  "${nombre}.tar.gz.gpg" ]; then
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

#borramos diferencial del sabado e incremental del domingo
if [ -e /backups/copias/"${maquina}_I_${fecha2}.tar.gz.gpg" ]; then
rm -r  /backups/copias/"${maquina}_I_${fecha2}.tar.gz.gpg"
fi

if [ -e /backups/copias/"${maquina}_D_${fecha3}.tar.gz.gpg" ]; then
rm -r /backups/copias/"${maquina}_D_${fecha3}.tar.gz.gpg"
fi

fi

if  [ "$vardia" != "lun" ]  && [ "$vardia" !=  "vie" ]; then

#desencriptamos la copia completa y la diferencial
gpg --batch --yes --passphrase "$pass" -o "${viernespasado}.tar.gz" -d "${viernespasado}.tar.gz.gpg"

#descomprimimos
tar xvf /backups/copias/"${viernespasado}.tar.gz"

#borramos el archivo comprimido
if [ -e "$viernespasado" ];then
rm -r "${viernespasado}.tar.gz"
fi

#comparamos la completa con los archivos
rsync -avh --compare-dest=/backups/copias/"$viernespasado"  user-copias@192.168.0.20:/var/www/html/nextcloud/data /backups/copias/"$nombre"

#borramos la completa sin comprimir
if [ -e "$viernespasado" ]; then
rm -r "$viernespasado"
fi

#Comprimimos la copia realizada

tar -czf "${nombre}.tar.gz"  "$nombre"

#Borramos el archivo sin comprimir
if [ -e "${nombre}.tar.gz" ]; then
rm -r "$nombre"
fi

#ciframos el archivo comprimido
gpg --symmetric --batch --yes --passphrase "$pass" "$nombre.tar.gz"

#borramos el archivo comprimido
if [ -e "${nombre}.tar.gz.gpg" ]; then
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

#borramos diferencial e incremental del dia anterior
if [ -e /backups/copias/"${maquina}_I_${fecha2}.tar.gz.gpg" ]; then
rm -r  /backups/copias/"${maquina}_I_${fecha2}.tar.gz.gpg"
fi

if [ -e /backups/copias/"${maquina}_D_${fecha2}.tar.gz.gpg" ]; then
rm -r /backups/copias/"${maquina}_D_${fecha2}.tar.gz.gpg"
fi

fi


if [ -e /backups/copias/"${nombre}.tar.gz.gpg" ];then
curl -d '{"token":"q9svodrm", "message":"'"$suma"'"}' -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -v -u "bot_nxc:uD+0L=882I" https://192.168.0.20/ocs/v2.php/apps/spreed/api/v1/chat/q9svodrm
else
curl -d '{"token":"q9svodrm", "message":"'"${nombre} Ha fallado "'"}' -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -v -u "bot_nxc:C--1G++.<<<>>>IEuBBiSdaK" https://192.168.0.20/ocs/v2.php/apps/spreed/api/v1/chat/q9svodrm

fi

