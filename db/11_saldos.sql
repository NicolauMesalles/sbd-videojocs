USE plataforma_jocs;
UPDATE usuaris u SET saldo_monedes =
  (SELECT COALESCE(SUM(monedes), 0) FROM recarregues r WHERE r.id_usuari = u.id_usuari)
  - (SELECT COALESCE(SUM(preu_pagat), 0) FROM compres c WHERE c.id_usuari = u.id_usuari);