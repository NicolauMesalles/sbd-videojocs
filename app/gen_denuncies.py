from faker import Faker

fake = Faker("es_ES")
Faker.seed(50)

motius = ["Insults", "Spam", "Llenguatge ofensiu", "Assetjament", "Suplantacio", "Contingut inapropiat"]

# 200 denuncies sobre missatges diferents (ids 1 a 3000). Les fa qui rep el missatge
# i MySQL agafa el receptor i la data del missatge. Moderadors: usuaris 3 a 10
sentencies = ["USE plataforma_jocs;"]
for i in range(200):
    id_missatge = fake.unique.random_int(1, 3000)
    motiu = fake.random_element(motius)
    minuts = fake.random_int(1, 4320)
    # les resoltes tenen moderador, les pendents no
    if fake.random_int(1, 10) <= 7:
        estat = "resolta"
        moderador = fake.random_int(3, 10)
    else:
        estat = "pendent"
        moderador = "NULL"
    data = f"LEAST(data + INTERVAL {minuts} MINUTE, '2026-10-17 12:00:00')"
    sentencies.append(f"INSERT INTO denuncies (motiu, estat, data, id_missatge, id_denunciant, id_moderador) SELECT '{motiu}', '{estat}', {data}, id_missatge, id_receptor, {moderador} FROM missatges WHERE id_missatge = {id_missatge};")

with open("db/10_denuncies.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sentencies) + "\n")