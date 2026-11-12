/*
============================================
                PART 1
01_lectura_bruta.sql
Necesites DOS terminals obertes, cadascuna amb:
docker exec -it BBDD_Videojocs mysql -u root -p plataforma_jocs
Sessió A = terminal 1 (la que actualitza)
Sessió B = terminal 2 (la que llegeix)
============================================
*/

-- [pas 1] SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT @@transaction_isolation; -- READ-UNCOMMITTED
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800

-- [pas 2] SESSIÓ A
START TRANSACTION;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14;-- 4800
UPDATE usuaris
SET saldo_monedes = saldo_monedes + 1000
WHERE id_usuari = 14; -- NO fem Commit

-- [pas 3] SESSIÓ B
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14; -- 5800

-- [pas 4] SESSIÓ A
ROLLBACK;

-- [pas 5] SESSIÓ B
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14; -- 4800


/*
============================================
                PART 2
Continuació, per veure com READ-COMITTED soluciona DIRTY READ
Sessió A = terminal 1 (la que actualitza)
Sessió B = terminal 2 (la que llegeix)
============================================
*/


-- [pas 1] SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation; -- READ-COMMITTED
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800

-- [pas 2] SESSIÓ A
START TRANSACTION;
UPDATE usuaris
SET saldo_monedes = saldo_monedes + 1000
WHERE id_usuari = 14; -- NO fem Commit
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14; -- 5800

-- [pas 3] SESSIÓ B
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 14; -- 4800 / Aquí veiem la comparativa.

-- [pas 4] SESSIÓ A
ROLLBACK;
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800


