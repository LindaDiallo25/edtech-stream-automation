import psycopg2
import time
import random
import os

def simulate_streaming():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        database='edtech_db',
        user='admin',
        password='password'
    )
    cur = conn.cursor()
    print("🚀 Simulateur EdTech démarré...")

    while True:
        student_id = random.choice([1, 2])
        lesson_id = random.choice([1, 2])
        watch_time = random.randint(30, 300)
        completion = random.randint(10, 100)
        
        cur.execute(
            "INSERT INTO streaming_logs (student_id, lesson_id, watch_time_seconds, completion_percentage) VALUES (%s, %s, %s, %s)",
            (student_id, lesson_id, watch_time, completion)
        )
        conn.commit()
        print(f"🎬 Étudiant {student_id} a regardé la leçon {lesson_id} ({completion}%)")
        time.sleep(10)

if __name__ == "__main__":
    simulate_streaming()