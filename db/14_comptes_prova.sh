#!/bin/bash
# m1: crea els 4 comptes de prova i els dona SELECT nomes sobre les vistes
# el nom de cada compte es el seu nom_usuari, aixi v_compres_jugador sap qui es
# la contrasenya surt de PROVES_PASSWORD del .env (sense cometes simples)

if [ -z "$PROVES_PASSWORD" ]; then
  echo "Falta PROVES_PASSWORD al .env"
  exit 1
fi

MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot plataforma_jocs <<SQL
-- jugadors (ids 13 i 15), moderador (id 3) i auditor (id 11)
CREATE USER 'jordiarranz'@'%' IDENTIFIED BY '$PROVES_PASSWORD';
CREATE USER 'hroura'@'%' IDENTIFIED BY '$PROVES_PASSWORD';
CREATE USER 'renatobartolome'@'%' IDENTIFIED BY '$PROVES_PASSWORD';
CREATE USER 'ojedajuan-jose'@'%' IDENTIFIED BY '$PROVES_PASSWORD';

GRANT SELECT ON v_compres_jugador TO 'jordiarranz'@'%', 'hroura'@'%';
GRANT SELECT ON v_perfil_usuaris TO 'renatobartolome'@'%', 'ojedajuan-jose'@'%';
GRANT SELECT ON v_missatges_denunciats TO 'renatobartolome'@'%';
GRANT SELECT ON v_tutors TO 'ojedajuan-jose'@'%';
SQL