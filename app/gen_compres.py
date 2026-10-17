from faker import Faker

fake = Faker("es_ES")
Faker.seed(48)

# jugadors adults: usuaris 13 a 412. Fem mes intents dels necessaris perque alguns es
# rebutgen (si l'usuari no te prou monedes), i al final ens quedem amb 1500 compres
sentencies = ["USE plataforma_jocs;"]
for i in range(2200):
    id_usuari = fake.random_int(13, 412)
    id_objecte = fake.random_int(1, 100)
    minuts = fake.random_int(1, 4320)
    # MySQL calcula el saldo (recarregues - compres) i nomes compra si el preu hi cap
    saldo = f"(SELECT COALESCE(SUM(monedes), 0) FROM recarregues WHERE id_usuari = {id_usuari}) - (SELECT COALESCE(SUM(preu_pagat), 0) FROM compres WHERE id_usuari = {id_usuari})"
    # la compra es fa despres de l'ultima recarrega (fins a 3 dies), sense passar d'avui
    data = f"LEAST((SELECT MAX(data) FROM recarregues WHERE id_usuari = {id_usuari}) + INTERVAL {minuts} MINUTE, '2026-10-17 12:00:00')"
    sentencies.append(f"INSERT INTO compres (preu_pagat, data, id_usuari, id_objecte) SELECT preu_monedes, {data}, {id_usuari}, {id_objecte} FROM objectes WHERE id_objecte = {id_objecte} AND preu_monedes <= {saldo};")
sentencies.append("DELETE FROM compres WHERE id_compra > 1500;")

with open("db/08_compres.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sentencies) + "\n")