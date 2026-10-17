from faker import Faker

fake = Faker("es_ES")
Faker.seed(44)

adjectius = ["Dark", "Neon", "Iron", "Lost", "Crystal", "Shadow", "Royal", "Wild", "Cosmic", "Frozen"]
noms = ["Dragons", "Legacy", "Arena", "Quest", "Kingdom", "Racers", "Hunters", "Legends", "Siege", "Frontier"]

# cada genere porta el seu PEGI, aixi un joc de terror no surt per a 3 anys
pegi_per_genere = {"Terror": 18, "Accio": 16, "RPG": 12, "Aventura": 12,
                   "Estrategia": 7, "Curses": 7, "Puzzle": 3, "Simulacio": 3}

titols = []
filas = []
while len(filas) < 20:
    titol = fake.random_element(adjectius) + " " + fake.random_element(noms)
    if titol in titols:
        continue
    titols.append(titol)
    genere = fake.random_element(list(pegi_per_genere))
    filas.append(f"('{titol}', '{genere}', {pegi_per_genere[genere]})")

sql = "USE plataforma_jocs;\nINSERT INTO jocs (titol, genere, pegi) VALUES\n" + ",\n".join(filas) + ";"

with open("db/04_jocs.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")