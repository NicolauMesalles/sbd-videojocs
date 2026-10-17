from faker import Faker

# llavor fixa perque tots tres generem exactament les mateixes dades
fake = Faker("es_ES")
Faker.seed(42)

# nif() de faker no respecta la llavor, aixi que el calculem nosaltres
LLETRES = "TRWAGMYFPDXBNJZSQVHLCKE"


def dni_nou():
    num = fake.unique.random_int(0, 99999999)
    return f"{num:08d}{LLETRES[num % 23]}"


filas = []
for i in range(40):
    nom = fake.first_name().replace("'", "''")
    cognoms = (fake.last_name() + " " + fake.last_name()).replace("'", "''")
    dni = dni_nou()
    email = fake.email()
    telefon = fake.numerify("6########")
    filas.append(f"('{nom}', '{cognoms}', '{dni}', '{email}', '{telefon}')")

sql = "USE plataforma_jocs;\nINSERT INTO tutors (nom, cognoms, dni, email, telefon) VALUES\n" + ",\n".join(filas) + ";"

with open("db/02_tutors.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")