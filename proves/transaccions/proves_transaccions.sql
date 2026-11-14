-- aqui hem de mirar q el saldo de tothom quadri, o sigui q saldo_monedes sigui les recarregues menys les compres
-- si surt 0 vol dir q no hi ha cap usuari descuadrat i q les dades de m0 estan be, si surt un altre numero algo falla
SELECT COUNT(*) AS saldos_que_no_quadren
FROM usuaris u
WHERE u.saldo_monedes <>
  (SELECT COALESCE(SUM(monedes), 0) FROM recarregues r WHERE r.id_usuari = u.id_usuari)
  - (SELECT COALESCE(SUM(preu_pagat), 0) FROM compres c WHERE c.id_usuari = u.id_usuari); -- 0

-- agafem el 13 pk te 950 monedes i li fem comprar l'objecte 2 q val 300
-- primer mirem com esta, dsp fem la compra i tornem a mirar, s'ha de quedar amb 650 i tenir una compra mes
-- si pasa aixo vol dir q el procediment ha fet les dos coses alhora i ha fet commit
SELECT saldo_monedes, (SELECT COUNT(*) FROM compres WHERE id_usuari = 13) AS compres
FROM usuaris WHERE id_usuari = 13; -- 950 | 4
CALL comprar_objecte(13, 2); -- saldo_restant 650
SELECT saldo_monedes, (SELECT COUNT(*) FROM compres WHERE id_usuari = 13) AS compres
FROM usuaris WHERE id_usuari = 13; -- 650 | 5

-- ara el mateix pero amb una recarrega de 10 euros, com 1 euro son 100 monedes li han d'entrar 1000
-- tenia 650 aixi q s'ha de quedar amb 1650 i tenir una recarrega mes
CALL recarregar_monedes(13, 1, 10.00); -- saldo_actual 1650
SELECT saldo_monedes, (SELECT COUNT(*) FROM recarregues WHERE id_usuari = 13) AS recarregues
FROM usuaris WHERE id_usuari = 13; -- 1650 | 3

-- ara venen els errors, per aixo agafem el 15 q te 100 monedes, 3 compres i 1 recarrega amb el metode 3
-- la idea es q dsp de cada error el 15 segueixi exactament igual, si canvia algo vol dir q el rollback no ha anat
SELECT saldo_monedes,
  (SELECT COUNT(*) FROM compres WHERE id_usuari = 15) AS compres,
  (SELECT COUNT(*) FROM recarregues WHERE id_usuari = 15) AS recarregues
FROM usuaris WHERE id_usuari = 15; -- 100 | 3 | 1

-- l'objecte 1 val 1000 i el 15 nomes en te 100, aixi q no li arriba
-- aqui la compra si q s'arriba a inserir, pero al restar el saldo queda negatiu i salta el check de saldo_monedes >= 0
-- llavors el rollback ha de treure la compra q ja estava posada, x aixo tornem a mirar i ha de tenir 3 compres igual
CALL comprar_objecte(15, 1);
-- ERROR 3819: Check constraint 'usuaris_chk_1' is violated.
SELECT saldo_monedes,
  (SELECT COUNT(*) FROM compres WHERE id_usuari = 15) AS compres,
  (SELECT COUNT(*) FROM recarregues WHERE id_usuari = 15) AS recarregues
FROM usuaris WHERE id_usuari = 15; -- 100 | 3 | 1

-- l'objecte 999 no existeix, aixi q ha de petar abans de fer res
CALL comprar_objecte(15, 999);
-- ERROR 1644: L'objecte no existeix

-- el metode 999 tampoc existeix, aqui no el comprovem nosaltres sino q peta la fk de recarregues
CALL recarregar_monedes(15, 999, 10.00);
-- ERROR 1452: Cannot add or update a child row: a foreign key constraint fails

-- el metode 2 es del 14, si el 15 intenta pagar amb ell no pot ser, nomes pots pagar amb lo teu
CALL recarregar_monedes(15, 2, 10.00);
-- ERROR 1644: El metode de pagament no es d'aquest usuari

-- recarregar -5 euros no te sentit, aqui salta el check de import_eur > 0
CALL recarregar_monedes(15, 3, -5.00);
-- ERROR 3819: Check constraint 'recarregues_chk_1' is violated.

-- a les dades de m0 no hi ha ningu suspes, aixi q suspenem el 15 nomes per provar-ho
-- si esta suspes no pot ni comprar ni recarregar, i dsp el tornem a posar actiu
UPDATE usuaris SET estat = 'suspes' WHERE id_usuari = 15;
CALL comprar_objecte(15, 3);
-- ERROR 1644: El compte no esta actiu, no pot comprar
CALL recarregar_monedes(15, 3, 10.00);
-- ERROR 1644: El compte no esta actiu, no pot recarregar
UPDATE usuaris SET estat = 'actiu' WHERE id_usuari = 15;

-- dsp de tots els errors el 15 ha d'estar igual q al principi, si es aixi vol dir q cap error ha deixat res a mitges
SELECT saldo_monedes,
  (SELECT COUNT(*) FROM compres WHERE id_usuari = 15) AS compres,
  (SELECT COUNT(*) FROM recarregues WHERE id_usuari = 15) AS recarregues
FROM usuaris WHERE id_usuari = 15; -- 100 | 3 | 1

-- aqui tornem a mirar q quadri tot dsp de comprar, recarregar i tots els errors
-- si no surt 0 es q algun procediment ha tocat el saldo pero no la taula o al reves, i aixo no pot pasar
SELECT COUNT(*) AS saldos_que_no_quadren
FROM usuaris u
WHERE u.saldo_monedes <>
  (SELECT COALESCE(SUM(monedes), 0) FROM recarregues r WHERE r.id_usuari = u.id_usuari)
  - (SELECT COALESCE(SUM(preu_pagat), 0) FROM compres c WHERE c.id_usuari = u.id_usuari); -- 0

-- i al final hem de deixar les dades com estaven pk sino la proxima vegada q fem les proves no surten els mateixos numeros
-- les dades de m0 acaben a la compra 1500 i la recarrega 800, aixi q tot lo q hi ha per sobre ho hem creat aqui i fora
-- dsp el saldo del 13 el tornem a calcular igual q a 11_saldos.sql i ja esta
DELETE FROM compres WHERE id_compra > 1500;
DELETE FROM recarregues WHERE id_recarrega > 800;
UPDATE usuaris u SET saldo_monedes =
  (SELECT COALESCE(SUM(monedes), 0) FROM recarregues r WHERE r.id_usuari = u.id_usuari)
  - (SELECT COALESCE(SUM(preu_pagat), 0) FROM compres c WHERE c.id_usuari = u.id_usuari)
WHERE u.id_usuari = 13;
SELECT saldo_monedes FROM usuaris WHERE id_usuari = 13; -- 950
SELECT COUNT(*) FROM compres; -- 1500
SELECT COUNT(*) FROM recarregues; -- 800