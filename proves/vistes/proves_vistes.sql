/*
proves de les vistes de m1
cada bloc es fa entrant amb el compte que diu, la contrasenya es PROVES_PASSWORD del .env:
docker exec -it BBDD_Videojocs mysql -u <compte> -p plataforma_jocs
*/

-- [1] vistes de columnes -> captura 01_columnes.png
-- compte: renatobartolome (moderador)
SELECT * FROM v_perfil_usuaris LIMIT 5; -- no hi ha email, hash, nom, data_naixement ni saldo
-- compte: ojedajuan-jose (auditor)
SELECT * FROM v_tutors LIMIT 5; -- no hi ha dni, email ni telefon

-- [2] mateixa vista, dos jugadors -> captura 02_compres_jugadors.png
-- compte: jordiarranz (id 13)
SELECT USER();
SELECT * FROM v_compres_jugador; -- 4 compres
-- compte: hroura (id 15)
SELECT USER();
SELECT * FROM v_compres_jugador; -- 3 compres, cap de les d'abans

-- [3] moderador -> captura 03_moderador.png
-- compte: renatobartolome
SELECT COUNT(*) FROM v_missatges_denunciats; -- 200, els 3000 del xat no
SELECT * FROM v_missatges_denunciats LIMIT 5;

-- [4] acces denegat a la taula base -> captura 04_acces_denegat.png
-- compte: jordiarranz
SELECT * FROM compres LIMIT 1; -- ERROR 1142 SELECT command denied
UPDATE v_compres_jugador SET preu_pagat = 1; -- ERROR 1142 UPDATE command denied
-- compte: renatobartolome
SELECT * FROM missatges LIMIT 1; -- ERROR 1142
