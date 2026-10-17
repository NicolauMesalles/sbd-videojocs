from faker import Faker

fake = Faker("es_ES")
Faker.seed(45)

articles = ["Espasa", "Escut", "Casc", "Capa", "Pocio", "Mascota", "Skin", "Arc"]
adjectius = ["Llegendari", "Antic", "Brillant", "Fosc", "Epic", "Rar", "Daurat", "Maleit"]
preus = [50, 100, 150, 200, 300, 500, 800, 1000]

# 5 objectes per cada un dels 20 jocs (ids de l'1 al 20)
filas = []
for id_joc in range(1, 21):
    for i in range(5):
        nom = fake.random_element(articles) + " " + fake.random_element(adjectius)
        preu = fake.random_element(preus)
        filas.append(f"('{nom}', {preu}, {id_joc})")

sql = "USE plataforma_jocs;\nINSERT INTO objectes (nom, preu_monedes, id_joc) VALUES\n" + ",\n".join(filas) + ";"

with open("db/05_objectes.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")