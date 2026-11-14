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

-- aqui tornem a mirar q quadri tot dsp de comprar i recarregar
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