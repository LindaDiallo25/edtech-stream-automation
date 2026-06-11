import os
import psycopg2
import time
import random
from datetime import datetime

# Configuration des accès (doit correspondre au docker-compose)
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "db"),
    "database": os.getenv("DB_NAME", "edtech_db"),
    "user": os.getenv("DB_USER", "admin"),
    "password": os.getenv("DB_PASS", "password")
}

def connect_to_db():
    """Tente de se connecter à la base de données en boucle jusqu'au succès."""
    while True:
        try:
            conn = psycopg2.connect(**DB_CONFIG)
            print("✅ Connexion réussie à PostgreSQL !")
            return conn
        except psycopg2.OperationalError:
            print("⏳ La base de données n'est pas encore prête... nouvel essai dans 2s")
            time.sleep(2)

def get_lesson_ids(cursor):
    cursor.execute("SELECT lesson_id FROM lessons;")
    rows = cursor.fetchall()
    return [row[0] for row in rows]


def get_student_ids(cursor):
    cursor.execute("SELECT student_id FROM students;")
    rows = cursor.fetchall()
    return [row[0] for row in rows]


def simulate_streaming():
    """Génère et insère des données d'élèves de manière aléatoire."""
    conn = connect_to_db()
    cursor = conn.cursor()

    names = ["Alice", "Bob", "Charlie", "David", "Eve", "Fatim", "Gabriel", "Hassan", "Ivy", "Jules", "Katia", "Liam", "Mia", "Nora", "Omar", "Paula", "Quentin", "Rita", "Sam", "Tina", "Uma", "Viktor", "Wendy", "Xavier", "Yara", "Zane", "Amir", "Bella", "Celine", "Dario", "Elena", "Felix", "Gina", "Hugo", "Isla", "Jack", "Kira", "Luca", "Maya", "Nico", "Olivia", "Pablo", "Queenie", "Rafael", "Sofia", "Theo", "Ursula", "Vera", "Will", "Xena", "Yusuf", "Zara", "Aria", "Bruno", "Clara", "Dylan", "Eva", "Finn", "Gloria", "Henry", "Irene", "Jake", "Kylie", "Leo", "Mila", "Nash", "Opal", "Prince", "Quincy", "Rose", "Sean", "Tara", "Ulric", "Violet", "Wade", "Ximena", "Yvonne", "Zion"]
    classrooms = ["Data_2025", "IA_2025", "Web_2025", "Cloud_2025", "Cybersec_2025", "DevOps_2025", "Mobile_2025", "GameDev_2025"]

    print("🚀 Démarrage de la simulation de données...")

    lesson_ids = get_lesson_ids(cursor)
    student_ids = get_student_ids(cursor)
    if not lesson_ids:
        print("⚠️ Aucune leçon disponible dans la base. Assurez-vous que `lessons` contient des données.")

    try:
        while True:
            stream_lesson_id = random.choice(lesson_ids) if lesson_ids else None
            watch_time_seconds = random.randint(30, 3600)
            completion_percentage = random.randint(0, 100)
            event_timestamp = datetime.utcnow()

            if student_ids and random.random() > 0.3:
                student_id = random.choice(student_ids)
                cursor.execute("SELECT classroom FROM students WHERE student_id = %s;", (student_id,))
                classroom = cursor.fetchone()[0]
                action = "existing"
            else:
                name = random.choice(names)
                classroom = random.choice(classrooms)
                cursor.execute(
                    "INSERT INTO students (name, classroom) VALUES (%s, %s) RETURNING student_id;",
                    (name, classroom)
                )
                student_id = cursor.fetchone()[0]
                student_ids.append(student_id)
                action = "new"

            if stream_lesson_id is not None:
                cursor.execute(
                    "INSERT INTO streaming_logs (student_id, lesson_id, watch_time_seconds, completion_percentage, event_timestamp) "
                    "VALUES (%s, %s, %s, %s, %s);",
                    (student_id, stream_lesson_id, watch_time_seconds, completion_percentage, event_timestamp)
                )

            conn.commit()

            if action == "new":
                print(
                    f"📥 Nouvel élève ajouté : {name} dans la classe {classroom} | "
                    f"log -> lesson_id={stream_lesson_id}, watch_time={watch_time_seconds}s, completion={completion_percentage}%"
                )
            else:
                print(
                    f"🔄 Élève existant {student_id} ({classroom}) enregistré | "
                    f"log -> lesson_id={stream_lesson_id}, watch_time={watch_time_seconds}s, completion={completion_percentage}%"
                )

            time.sleep(5)

    except Exception as e:
        print(f"❌ Erreur pendant la simulation : {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    simulate_streaming()