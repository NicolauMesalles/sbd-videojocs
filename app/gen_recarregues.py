from datetime import datetime

from faker import Faker

fake = Faker("es_ES")
Faker.seed(47)

# 800 recarregues: les 400 primeres una per metode, la resta a l'atzar
# el metode n es de l'usuari n + 12 (jugadors 13 a 412)
filas = []
for i in range(800):
    if i < 400:
        id_metode = i + 1
    else:
        id_metode = fake.random_int(1, 400)
    id_usuari = id_metode + 12
    import_eur = fake.random_element([5, 10, 20, 50])
    monedes = import_eur * 100
    # despres del ultim registre d'usuari, aixi mai es recarrega abans de ser usuari
    data = fake.date_time_between_dates(datetime(2026, 4, 18), datetime(2026, 10, 17))
    filas.append(f"({import_eur}, {monedes}, '{data}', {id_usuari}, {id_metode})")

sql = "USE plataforma_jocs;\nINSERT INTO recarregues (import_eur, monedes, data, id_usuari, id_metode) VALUES\n" + ",\n".join(filas) + ";"

with open("db/07_recarregues.sql", "w", encoding="utf-8") as f:
    f.write(sql + "\n")