/*
============================================
                PART 1
02_no_repetible.sql
Anomalia: lectura no repetible, amb READ COMMITTED
Necessites DOS terminals obertes, cadascuna amb:
docker exec -it BBDD_Videojocs mysql -u root -p plataforma_jocs
Sessió A = terminal 1 (la que actualitza)
Sessió B = terminal 2 (la que llegeix)
============================================
*/

-- [pas 1] SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation; -- READ-COMMITTED
START TRANSACTION;
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800

-- [pas 2] SESSIÓ A
START TRANSACTION;
UPDATE usuaris
SET saldo_monedes = saldo_monedes + 1000
WHERE id_usuari = 14; 
COMMIT;

-- [pas 3] SESSIÓ B
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 5800
COMMIT;

-- [pas 4] RESTAURAR
UPDATE usuaris
SET saldo_monedes = saldo_monedes - 1000
WHERE id_usuari = 14; 
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800



/*
============================================
                PART 2
Continuació, per veure com REPEATABLE READ soluciona la lectura no repetible
Sessió A = terminal 1 (la que actualitza)
Sessió B = terminal 2 (la que llegeix)
============================================
*/

-- [pas 1] SESSIÓ B
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation; -- REPEATABLE-READ
START TRANSACTION;
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800

-- [pas 2] SESSIÓ A
START TRANSACTION;
UPDATE usuaris
SET saldo_monedes = saldo_monedes + 1000
WHERE id_usuari = 14; 
COMMIT;

-- [pas 3] SESSIÓ B
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800
COMMIT;
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 5800

-- [pas 4] RESTAURAR
UPDATE usuaris
SET saldo_monedes = saldo_monedes - 1000
WHERE id_usuari = 14; 
SELECT saldo_monedes FROM usuaris where id_usuari = 14; -- 4800

