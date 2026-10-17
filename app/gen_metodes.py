from faker import Faker

fake = Faker("es_ES")
Faker.seed(46)

# els usuaris 13 a 412 son jugadors adults (els menors no tenen targeta propia)
filas = []
for id_usuari in range(13, 413):
    tipus = fake.random_element(["targeta", "paypal", "bizum"])
    titular = fake.name().replace("'", "''")
    # de la targeta nomes guardem els 4 ultims digits, mai el numero sencer
    if tipus == "targeta":
        ultims4 = "'" + fake.numerify("####") + "'"
    else:
        ultims4 = "NULL"
    filas.append(f"('{tipus}', '{titular}', {ultims4}, {id_usuari})")

sql = "USE plataforma_jocs;\nINSERT INTO metodes_pagament (tipus, titular, ultims4, id_usuari) VALUES\n" + ",\n".join(filas) + ";"

with open("db/06_metodes_pagament.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")