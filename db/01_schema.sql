-- projecte sbd cas 4 plataforma de videojocs online
-- esquema de la base de dades per la m0

CREATE DATABASE IF NOT EXISTS plataforma_jocs;
USE plataforma_jocs;

-- els perfils que pot tenir un usuari
CREATE TABLE rols (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(20) NOT NULL UNIQUE
);

-- els posem ja aqui perque sempre son els mateixos
INSERT INTO rols (nom) VALUES ('administrador'), ('moderador'), ('auditor'), ('jugador');

-- pares o tutors dels usuaris que tenen menys de 14 anys
CREATE TABLE tutors (
  id_tutor INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(50) NOT NULL,
  cognoms VARCHAR(100) NOT NULL,
  dni VARCHAR(9) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL,
  telefon VARCHAR(15)
);

CREATE TABLE usuaris (
  id_usuari INT AUTO_INCREMENT PRIMARY KEY,
  nom_usuari VARCHAR(30) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  hash_contrasenya VARCHAR(255) NOT NULL,
  nom VARCHAR(50) NOT NULL,
  cognoms VARCHAR(100) NOT NULL,
  data_naixement DATE NOT NULL,
  saldo_monedes INT NOT NULL DEFAULT 0,
  estat ENUM('actiu', 'suspes', 'expulsat') NOT NULL DEFAULT 'actiu',
  data_registre DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_rol INT NOT NULL,
  id_tutor INT,
  FOREIGN KEY (id_rol) REFERENCES rols(id_rol),
  FOREIGN KEY (id_tutor) REFERENCES tutors(id_tutor),
  CHECK (saldo_monedes >= 0)
);

CREATE TABLE jocs (
  id_joc INT AUTO_INCREMENT PRIMARY KEY,
  titol VARCHAR(100) NOT NULL,
  genere VARCHAR(30),
  pegi INT NOT NULL,
  CHECK (pegi IN (3, 7, 12, 16, 18))
);

-- les coses que es poden comprar dins de cada joc
CREATE TABLE objectes (
  id_objecte INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(50) NOT NULL,
  preu_monedes INT NOT NULL,
  id_joc INT NOT NULL,
  FOREIGN KEY (id_joc) REFERENCES jocs(id_joc),
  CHECK (preu_monedes > 0)
);

-- de la targeta nomes guardem els 4 ultims numeros, mai el numero sencer ni el cvv
CREATE TABLE metodes_pagament (
  id_metode INT AUTO_INCREMENT PRIMARY KEY,
  tipus ENUM('targeta', 'paypal', 'bizum') NOT NULL,
  titular VARCHAR(100) NOT NULL,
  ultims4 CHAR(4),
  id_usuari INT NOT NULL,
  FOREIGN KEY (id_usuari) REFERENCES usuaris(id_usuari)
);

-- quan l'usuari paga amb diners de veritat per tenir monedes
CREATE TABLE recarregues (
  id_recarrega INT AUTO_INCREMENT PRIMARY KEY,
  import_eur DECIMAL(6,2) NOT NULL,
  monedes INT NOT NULL,
  data DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_usuari INT NOT NULL,
  id_metode INT NOT NULL,
  FOREIGN KEY (id_usuari) REFERENCES usuaris(id_usuari),
  FOREIGN KEY (id_metode) REFERENCES metodes_pagament(id_metode),
  CHECK (import_eur > 0)
);

-- quan l'usuari gasta monedes en un objecte
-- guardem el preu que va pagar per si despres el preu canvia
CREATE TABLE compres (
  id_compra INT AUTO_INCREMENT PRIMARY KEY,
  preu_pagat INT NOT NULL,
  data DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_usuari INT NOT NULL,
  id_objecte INT NOT NULL,
  FOREIGN KEY (id_usuari) REFERENCES usuaris(id_usuari),
  FOREIGN KEY (id_objecte) REFERENCES objectes(id_objecte)
);

-- missatges del xat entre jugadors
CREATE TABLE missatges (
  id_missatge INT AUTO_INCREMENT PRIMARY KEY,
  contingut VARCHAR(500) NOT NULL,
  data DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_emissor INT NOT NULL,
  id_receptor INT NOT NULL,
  FOREIGN KEY (id_emissor) REFERENCES usuaris(id_usuari),
  FOREIGN KEY (id_receptor) REFERENCES usuaris(id_usuari)
);

-- denuncies dels missatges, el moderador queda buit fins que algu la revisa
CREATE TABLE denuncies (
  id_denuncia INT AUTO_INCREMENT PRIMARY KEY,
  motiu VARCHAR(100) NOT NULL,
  estat ENUM('pendent', 'resolta') NOT NULL DEFAULT 'pendent',
  data DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_missatge INT NOT NULL,
  id_denunciant INT NOT NULL,
  id_moderador INT,
  FOREIGN KEY (id_missatge) REFERENCES missatges(id_missatge),
  FOREIGN KEY (id_denunciant) REFERENCES usuaris(id_usuari),
  FOREIGN KEY (id_moderador) REFERENCES usuaris(id_usuari)
);

-- si l'usuari te menys de 14 anys ha de tenir tutor, ho diu la llei de proteccio de dades
-- no ho podem fer amb un check perque mysql no deixa posar curdate dins
DELIMITER //

CREATE TRIGGER comprovar_tutor_insert
BEFORE INSERT ON usuaris
FOR EACH ROW
BEGIN
  IF TIMESTAMPDIFF(YEAR, NEW.data_naixement, CURDATE()) < 14 AND NEW.id_tutor IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un menor de 14 anys necessita tutor';
  END IF;
END //

-- el mateix pero quan es modifica, perque no li puguin treure el tutor despres
CREATE TRIGGER comprovar_tutor_update
BEFORE UPDATE ON usuaris
FOR EACH ROW
BEGIN
  IF TIMESTAMPDIFF(YEAR, NEW.data_naixement, CURDATE()) < 14 AND NEW.id_tutor IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un menor de 14 anys necessita tutor';
  END IF;
END //

DELIMITER ;
