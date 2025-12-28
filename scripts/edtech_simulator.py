import psycopg2
import time
import random
from datetime import datetime

# Configuration des accès (doit correspondre au docker-compose)
DB_CONFIG = {
    "host": "db",
    "database": "edtech_db",
    "user": "admin",
    "password": "password"
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

def simulate_streaming():
    """Génère et insère des données d'élèves de manière aléatoire."""
    conn = connect_to_db()
    cursor = conn.cursor()

    names = ["Alice", "Bob", "Charlie", "David", "Eve", "Fatim", "Gabriel", "Hassan", "Ivy", "Jules", "Katia", "Liam", "Mia", "Nora", "Omar", "Paula", "Quentin", "Rita", "Sam", "Tina", "Uma", "Viktor", "Wendy", "Xavier", "Yara", "Zane", "Amir", "Bella", "Celine", "Dario", "Elena", "Felix", "Gina", "Hugo", "Isla", "Jack", "Kira", "Luca", "Maya", "Nico", "Olivia", "Pablo", "Queenie", "Rafael", "Sofia", "Theo", "Ursula", "Vera", "Will", "Xena", "Yusuf", "Zara", "Aria", "Bruno", "Clara", "Dylan", "Eva", "Finn", "Gloria", "Henry", "Irene", "Jake", "Kylie", "Leo", "Mila", "Nash", "Opal", "Prince", "Quincy", "Rose", "Sean", "Tara", "Ulric", "Violet", "Wade", "Ximena", "Yvonne", "Zion"]
    classrooms = ["Data_2025", "IA_2025", "Web_2025", "Cloud_2025", "Cybersec_2025", "DevOps_2025", "Mobile_2025", "GameDev_2025"]

    print("🚀 Démarrage de la simulation de données...")

    try:
        while True:
            # Choisir un élève et une classe au hasard
            name = random.choice(names)
            classroom = random.choice(classrooms)
            
            # Insertion SQL
            query = "INSERT INTO students (name, classroom) VALUES (%s, %s);"
            cursor.execute(query, (name, classroom))
            
            # Valider la transaction
            conn.commit()
            
            print(f"📥 Nouvel élève ajouté : {name} dans la classe {classroom}")
            
            # Attendre 5 secondes avant la prochaine donnée pour simuler un "flux"
            time.sleep(5)

    except Exception as e:
        print(f"❌ Erreur pendant la simulation : {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    simulate_streaming()