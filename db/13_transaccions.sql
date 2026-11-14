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