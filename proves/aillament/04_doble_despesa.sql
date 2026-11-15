/*
============================================
                PART 1
04_doble_despesa.sql
Problema: dues compres alhora del mateix usuari gasten el mateix saldo (R12)
Sense procediment: cada sessió llegeix el saldo, calcula i escriu
Taules: usuaris i compres, usuari 14, objecte 98
Necessites DOS terminals obertes, cadascuna amb:
docker exec -it BBDD_Videojocs mysql -u root -p plataforma_jocs
Sessió A = terminal 1
Sessió B = terminal 2
============================================
*/

-- [pas 0] PUNT DE REFERÈNCIA (qualsevol sessió)
SELECT saldo_monedes, estat FROM usuaris WHERE id_usuari = 14;  -- 4800, actiu
SELECT preu_monedes FROM objectes WHERE id_objecte = 98;        -- 150
SELECT COUNT(*) FROM compres WHERE id_usuari = 14;              -- 3

-- [pas 1] SESSIÓ A
START TRANSACTION;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 4800

-- [pas 2] SESSIÓ B
START TRANSACTION;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 4800

-- [pas 3] SESSIÓ A
INSERT INTO compres (preu_pagat, id_usuari, id_objecte) VALUES (150, 14, 98);
SELECT LAST_INSERT_ID();  -- Anota el número
UPDATE usuaris SET saldo_monedes = 4650 WHERE id_usuari = 14;
COMMIT;

-- [pas 4] SESSIÓ B
INSERT INTO compres (preu_pagat, id_usuari, id_objecte) VALUES (150, 14, 98);
SELECT LAST_INSERT_ID();  -- Anota el número
UPDATE usuaris SET saldo_monedes = 4650 WHERE id_usuari = 14;
COMMIT;

-- [pas 5] COMPROVACIÓ
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 4650
SELECT COUNT(*) FROM compres WHERE id_usuari = 14;       -- 5


-- [pas 6] RESTAURAR
DELETE FROM compres WHERE id_compra IN (1840, 1841);  -- els dos números apuntats
UPDATE usuaris SET saldo_monedes = 4800 WHERE id_usuari = 14;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 4800
SELECT COUNT(*) FROM compres WHERE id_usuari = 14;       -- 3



/*
============================================
                PART 2
Continuació, per veure com el procediment comprar_objecte evita la doble despesa
(SELECT ... FOR UPDATE sobre la fila de l'usuari)
Sessió A = terminal 1 (compra a mitges, té la fila bloquejada)
Sessió B = terminal 2 (crida el procediment)
============================================
*/

-- [pas 0] PREPARACIÓ (qualsevol sessió)
UPDATE usuaris SET saldo_monedes = 150 WHERE id_usuari = 14;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 150

-- [pas 0] PREPARACIÓ SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation;  -- REPEATABLE-READ

-- [pas 1] SESSIÓ A
START TRANSACTION;
SELECT estat FROM usuaris WHERE id_usuari = 14 FOR UPDATE;  -- actiu


-- [pas 2] SESSIÓ B
CALL comprar_objecte(14, 98); -- B es queda esperant, amb un temps màxim de 50 segons


-- [pas 3] SESSIÓ A
INSERT INTO compres (preu_pagat, id_usuari, id_objecte) VALUES (150, 14, 98);
SELECT LAST_INSERT_ID();  -- Anota el número
UPDATE usuaris SET saldo_monedes = saldo_monedes - 150 WHERE id_usuari = 14;
COMMIT;


-- [pas 4] SESSIÓ B
-- El CALL es desbloqueja i falla amb l'error del CHECK del saldo 
-- mysql> CALL comprar_objecte(14, 98); 
-- ERROR 3819 (HY000): Check constraint 'usuaris_chk_1' is violated.

-- [pas 5] COMPROVACIÓ
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 0
SELECT COUNT(*) FROM compres WHERE id_usuari = 14;       -- 4


-- [pas 6] RESTAURAR
DELETE FROM compres WHERE id_compra = 1842;  -- el número anotat
UPDATE usuaris SET saldo_monedes = 4800 WHERE id_usuari = 14;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;  -- 4800
SELECT COUNT(*) FROM compres WHERE id_usuari = 14;       -- 3