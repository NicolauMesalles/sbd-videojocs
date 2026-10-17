from datetime import datetime

from faker import Faker

fake = Faker("es_ES")
Faker.seed(49)

# 3000 missatges entre usuaris (ids 1 a 500), sempre despres del ultim registre
filas = []
for i in range(3000):
    emissor = fake.random_int(1, 500)
    receptor = fake.random_int(1, 500)
    # no es pot enviar un missatge a un mateix
    while receptor == emissor:
        receptor = fake.random_int(1, 500)
    contingut = fake.sentence(nb_words=10).replace("'", "''")
    data = fake.date_time_between_dates(datetime_start=datetime(2026, 4, 18), datetime_end=datetime(2026, 10, 17)).replace(microsecond=0)
    filas.append(f"('{contingut}', '{data}', {emissor}, {receptor})")

sql = "USE plataforma_jocs;\nINSERT INTO missatges (contingut, data, id_emissor, id_receptor) VALUES\n" + ",\n".join(filas) + ";"

with open("db/09_missatges.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")