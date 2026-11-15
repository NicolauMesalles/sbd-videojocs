/*
============================================
                PART 1
03_fantasma.sql
Anomalia: lectura fantasma, amb READ COMMITTED
Taula: compres, usuari 14
Necessites DOS terminals obertes, cadascuna amb:
docker exec -it BBDD_Videojocs mysql -u root -p plataforma_jocs
Sessió A = terminal 1 (la que insereix)
Sessió B = terminal 2 (la que llegeix)
============================================
*/

-- [pas 0] PUNT DE REFERÈNCIA (qualsevol sessió)
SELECT id_objecte, preu_monedes FROM objectes WHERE id_objecte = 98; -- 98, 150
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 3

-- [pas 1] SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation; -- READ-COMMITTED
START TRANSACTION;
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 3

-- [pas 2] SESSIÓ A
START TRANSACTION;
INSERT INTO compres (preu_pagat, id_usuari, id_objecte)
VALUES (100, 14, 98);
SELECT LAST_INSERT_ID();
COMMIT;

-- [pas 3] SESSIÓ B
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 4 
COMMIT;

-- [pas 4] RESTAURAR
DELETE FROM compres WHERE id_compra = 1838; -- substitueix 1838 pel valor de LAST_INSERT_ID()
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 3



/*
============================================
                PART 2
Continuació, per veure com REPEATABLE READ soluciona la lectura fantasma
Sessió A = terminal 1 (la que insereix)
Sessió B = terminal 2 (la que llegeix)
============================================
*/

-- [pas 1] SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation; -- REPEATABLE-READ
START TRANSACTION;
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 3

-- [pas 2] SESSIÓ A
START TRANSACTION;
INSERT INTO compres (preu_pagat, id_usuari, id_objecte)
VALUES (100, 14, 98);
SELECT LAST_INSERT_ID(); 
COMMIT;

-- [pas 3] SESSIÓ B
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 3 
COMMIT;
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 4 

-- [pas 4] RESTAURAR
DELETE FROM compres WHERE id_compra = 1839; -- substitueix 1839 pel valor de LAST_INSERT_ID()
SELECT COUNT(*) FROM compres WHERE id_usuari = 14; -- 3
