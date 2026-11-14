-- m1: vistes de seguretat
-- 2 vistes que amaguen columnes (perfil i tutors) i 2 que filtren files (compres del jugador i missatges denunciats)
-- es creen amb root, aixi que s'executen amb els permisos de root (SQL SECURITY DEFINER, el que hi ha per defecte)
-- i els comptes de prova nomes necessiten SELECT sobre la vista, no sobre la taula

USE plataforma_jocs;

-- perfil d'usuari sense email, hash, nom, cognoms, data de naixement ni saldo (R13)
CREATE VIEW v_perfil_usuaris AS
SELECT id_usuari, nom_usuari, id_rol, estat, data_registre
FROM usuaris;

-- tutors per a l'auditor, sense dni, email ni telefon (R09)
CREATE VIEW v_tutors AS
SELECT id_tutor, nom, cognoms
FROM tutors;

-- cada jugador veu nomes les seves compres
-- USER() i no CURRENT_USER(), perque dins d'una vista definer CURRENT_USER() es root
CREATE VIEW v_compres_jugador AS
SELECT c.id_compra, o.nom AS objecte, c.preu_pagat, c.data
FROM compres c
JOIN objectes o ON o.id_objecte = c.id_objecte
JOIN usuaris u ON u.id_usuari = c.id_usuari
WHERE u.nom_usuari = SUBSTRING_INDEX(USER(), '@', 1);

-- el moderador nomes veu els missatges que tenen denuncia, no tot el xat (R06)
CREATE VIEW v_missatges_denunciats AS
SELECT m.id_missatge, m.contingut, m.data, m.id_emissor, d.id_denuncia, d.motiu, d.estat
FROM missatges m
JOIN denuncies d ON d.id_missatge = m.id_missatge;