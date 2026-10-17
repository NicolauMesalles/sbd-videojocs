from datetime import date, datetime

from faker import Faker

fake = Faker("es_ES")
Faker.seed(43)

filas = []
for i in range(1, 501):
    # 1-2 administrador, 3-10 moderador, 11-12 auditor, la resta jugadors
    if i <= 2:
        rol = 1
    elif i <= 10:
        rol = 2
    elif i <= 12:
        rol = 3
    else:
        rol = 4

    # els ultims 60 son menors de 14 anys i han de tenir tutor
    if i > 440:
        naixement = fake.date_between_dates(date(2013, 10, 18), date(2018, 10, 17))
        tutor = fake.random_int(1, 40)
    else:
        naixement = fake.date_between_dates(date(1966, 1, 1), date(2008, 1, 1))
        tutor = "NULL"

    registre = fake.date_time_between_dates(datetime(2023, 10, 17), datetime(2026, 4, 17))
    nom = fake.first_name().replace("'", "''")
    cognoms = (fake.last_name() + " " + fake.last_name()).replace("'", "''")
    nom_usuari = fake.unique.user_name()[:30]
    email = fake.unique.email()
    contrasenya = fake.sha256()
    filas.append(f"({i}, '{nom_usuari}', '{email}', '{contrasenya}', '{nom}', '{cognoms}', '{naixement}', 0, '{registre}', {rol}, {tutor})")

sql = "USE plataforma_jocs;\nINSERT INTO usuaris (id_usuari, nom_usuari, email, hash_contrasenya, nom, cognoms, data_naixement, saldo_monedes, data_registre, id_rol, id_tutor) VALUES\n" + ",\n".join(filas) + ";"

with open("db/03_usuaris.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")