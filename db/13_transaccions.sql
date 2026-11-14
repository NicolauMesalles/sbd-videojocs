USE plataforma_jocs;

-- les dues operacions on es mouen monedes van com a procediments perque aixi el handler
-- pot fer rollback davant de qualsevol error, cosa que un script solt no pot decidir

DROP PROCEDURE IF EXISTS comprar_objecte;

DELIMITER //

CREATE PROCEDURE comprar_objecte(IN p_id_usuari INT, IN p_id_objecte INT)
BEGIN
  DECLARE v_estat VARCHAR(10);
  DECLARE v_preu INT;
  DECLARE v_id_compra INT;

  -- sigui quin sigui l'error (check, fk o els nostres signal) es desfa tot
  -- i el resignal fa que l'error original arribi a qui ha cridat el procediment
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- el for update bloqueja la fila de l'usuari fins al commit, aixi dues compres
  -- alhora del mateix usuari fan cua i no es pot gastar el mateix saldo dos cops (R12)
  SELECT estat INTO v_estat FROM usuaris WHERE id_usuari = p_id_usuari FOR UPDATE;

  IF v_estat IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''usuari no existeix';
  END IF;

  IF v_estat <> 'actiu' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El compte no esta actiu, no pot comprar';
  END IF;

  -- el preu el treiem de la taula i no de qui crida, perque no es pugui comprar a un preu inventat
  SELECT preu_monedes INTO v_preu FROM objectes WHERE id_objecte = p_id_objecte;

  IF v_preu IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''objecte no existeix';
  END IF;

  INSERT INTO compres (preu_pagat, id_usuari, id_objecte)
  VALUES (v_preu, p_id_usuari, p_id_objecte);
  SET v_id_compra = LAST_INSERT_ID();

  -- descomptem despres d'inserir: si no hi ha prou saldo salta el check saldo_monedes >= 0
  -- i el rollback ha de treure tambe la compra que ja s'havia inserit
  UPDATE usuaris SET saldo_monedes = saldo_monedes - v_preu WHERE id_usuari = p_id_usuari;

  COMMIT;

  SELECT v_id_compra AS id_compra, v_preu AS preu_pagat, saldo_monedes AS saldo_restant
  FROM usuaris WHERE id_usuari = p_id_usuari;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS recarregar_monedes;

DELIMITER //

CREATE PROCEDURE recarregar_monedes(IN p_id_usuari INT, IN p_id_metode INT, IN p_import_eur DECIMAL(6,2))
BEGIN
  DECLARE v_estat VARCHAR(10);
  DECLARE v_propietari INT;
  DECLARE v_monedes INT;
  DECLARE v_id_recarrega INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- tambe bloquegem l'usuari, perque una recarrega i una compra alhora no es trepitgin el saldo
  SELECT estat INTO v_estat FROM usuaris WHERE id_usuari = p_id_usuari FOR UPDATE;

  IF v_estat IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''usuari no existeix';
  END IF;

  IF v_estat <> 'actiu' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El compte no esta actiu, no pot recarregar';
  END IF;

  -- un usuari no pot pagar amb el metode d'un altre. Si el metode no existeix v_propietari
  -- queda null, la comparacio no es compleix i ja ho atura la fk de l'insert
  SELECT id_usuari INTO v_propietari FROM metodes_pagament WHERE id_metode = p_id_metode;

  IF v_propietari <> p_id_usuari THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El metode de pagament no es d''aquest usuari';
  END IF;

  -- 1 euro son 100 monedes, igual que a les dades de m0
  SET v_monedes = ROUND(p_import_eur * 100);

  -- si l'import no es positiu salta el check import_eur > 0
  INSERT INTO recarregues (import_eur, monedes, id_usuari, id_metode)
  VALUES (p_import_eur, v_monedes, p_id_usuari, p_id_metode);
  SET v_id_recarrega = LAST_INSERT_ID();

  UPDATE usuaris SET saldo_monedes = saldo_monedes + v_monedes WHERE id_usuari = p_id_usuari;

  COMMIT;

  SELECT v_id_recarrega AS id_recarrega, v_monedes AS monedes, saldo_monedes AS saldo_actual
  FROM usuaris WHERE id_usuari = p_id_usuari;
END //

DELIMITER ;