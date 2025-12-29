from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import RealDictCursor

# Configuration de la base de données
DB_CONFIG = {
    "host": "db",
    "database": "edtech_db",
    "user": "admin",
    "password": "password",
    "port": 5432
}

def get_db_connection():
    """Établit une connexion à la base de données PostgreSQL."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"❌ Erreur de connexion à la base de données : {e}")
        raise

def analyze_student_engagement(**context):
    """Analyse l'engagement des étudiants par classe."""
    print("📊 Analyse de l'engagement des étudiants en cours...")
    
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Calculer le nombre total d'étudiants par classe
        query = """
            SELECT classroom, COUNT(*) as total_students
            FROM students
            GROUP BY classroom
            ORDER BY total_students DESC;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        
        print("\n📈 Répartition des étudiants par classe :")
        for row in results:
            print(f"  - {row['classroom']}: {row['total_students']} étudiants")
        
        # Calculer le nombre total d'étudiants
        cursor.execute("SELECT COUNT(*) as total FROM students;")
        total = cursor.fetchone()['total']
        print(f"\n✅ Nombre total d'étudiants : {total}")
        
    except Exception as e:
        print(f"❌ Erreur lors de l'analyse : {e}")
        raise
    finally:
        cursor.close()
        conn.close()

def analyze_lesson_completion(**context):
    """Analyse le taux de complétion des leçons."""
    print("📚 Analyse du taux de complétion des leçons en cours...")
    
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Calculer le taux de complétion moyen par leçon
        query = """
            SELECT 
                l.lesson_id,
                l.title,
                l.subject,
                COUNT(sl.log_id) as total_views,
                AVG(sl.completion_percentage) as avg_completion,
                AVG(sl.watch_time_seconds) as avg_watch_time
            FROM lessons l
            LEFT JOIN streaming_logs sl ON l.lesson_id = sl.lesson_id
            GROUP BY l.lesson_id, l.title, l.subject
            ORDER BY avg_completion DESC NULLS LAST;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        
        print("\n📊 Statistiques par leçon :")
        for row in results:
            if row['total_views']:
                print(f"  - {row['title']} ({row['subject']}):")
                print(f"    • Vues: {row['total_views']}")
                print(f"    • Complétion moyenne: {row['avg_completion']:.2f}%")
                print(f"    • Temps de visionnage moyen: {row['avg_watch_time']:.2f}s")
            else:
                print(f"  - {row['title']} ({row['subject']}): Aucune vue")
        
    except Exception as e:
        print(f"❌ Erreur lors de l'analyse : {e}")
        raise
    finally:
        cursor.close()
        conn.close()

def analyze_classroom_performance(**context):
    """Analyse les performances par classe."""
    print("🎓 Analyse des performances par classe en cours...")
    
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Calculer les statistiques par classe
        query = """
            SELECT 
                s.classroom,
                COUNT(DISTINCT s.student_id) as total_students,
                COUNT(sl.log_id) as total_streaming_events,
                AVG(sl.completion_percentage) as avg_completion,
                AVG(sl.watch_time_seconds) as avg_watch_time
            FROM students s
            LEFT JOIN streaming_logs sl ON s.student_id = sl.student_id
            GROUP BY s.classroom
            ORDER BY avg_completion DESC NULLS LAST;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        
        print("\n🏆 Performances par classe :")
        for row in results:
            print(f"  - {row['classroom']}:")
            print(f"    • Étudiants: {row['total_students']}")
            print(f"    • Événements de streaming: {row['total_streaming_events']}")
            if row['avg_completion']:
                print(f"    • Complétion moyenne: {row['avg_completion']:.2f}%")
                print(f"    • Temps de visionnage moyen: {row['avg_watch_time']:.2f}s")
            else:
                print(f"    • Aucune donnée de streaming disponible")
        
    except Exception as e:
        print(f"❌ Erreur lors de l'analyse : {e}")
        raise
    finally:
        cursor.close()
        conn.close()

def generate_daily_report(**context):
    """Génère un rapport quotidien résumé."""
    print("📋 Génération du rapport quotidien...")
    
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Statistiques globales
        cursor.execute("SELECT COUNT(*) as total FROM students;")
        total_students = cursor.fetchone()['total']
        
        cursor.execute("SELECT COUNT(*) as total FROM lessons;")
        total_lessons = cursor.fetchone()['total']
        
        cursor.execute("SELECT COUNT(*) as total FROM streaming_logs;")
        total_logs = cursor.fetchone()['total']
        
        cursor.execute("""
            SELECT AVG(completion_percentage) as avg_completion 
            FROM streaming_logs 
            WHERE completion_percentage IS NOT NULL;
        """)
        result = cursor.fetchone()
        avg_completion = result['avg_completion'] if result['avg_completion'] else 0
        
        print("\n" + "="*50)
        print("📊 RAPPORT QUOTIDIEN - EdTech Analytics")
        print("="*50)
        print(f"👥 Nombre total d'étudiants: {total_students}")
        print(f"📚 Nombre total de leçons: {total_lessons}")
        print(f"📺 Événements de streaming: {total_logs}")
        print(f"✅ Taux de complétion moyen: {avg_completion:.2f}%")
        print("="*50)
        
    except Exception as e:
        print(f"❌ Erreur lors de la génération du rapport : {e}")
        raise
    finally:
        cursor.close()
        conn.close()

# Définition du DAG
default_args = {
    'owner': 'edtech_team',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'edtech_analytics',
    default_args=default_args,
    description='DAG pour l\'analyse automatisée des données EdTech',
    schedule_interval='@daily',  # Exécution quotidienne
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['edtech', 'analytics', 'education'],
) as dag:
    
    # Tâche 1: Analyser l'engagement des étudiants
    task_student_engagement = PythonOperator(
        task_id='analyze_student_engagement',
        python_callable=analyze_student_engagement,
        provide_context=True,
    )
    
    # Tâche 2: Analyser le taux de complétion des leçons
    task_lesson_completion = PythonOperator(
        task_id='analyze_lesson_completion',
        python_callable=analyze_lesson_completion,
        provide_context=True,
    )
    
    # Tâche 3: Analyser les performances par classe
    task_classroom_performance = PythonOperator(
        task_id='analyze_classroom_performance',
        python_callable=analyze_classroom_performance,
        provide_context=True,
    )
    
    # Tâche 4: Générer le rapport quotidien (dépend des autres tâches)
    task_daily_report = PythonOperator(
        task_id='generate_daily_report',
        python_callable=generate_daily_report,
        provide_context=True,
    )
    
    # Définir l'ordre d'exécution
    # Les trois premières tâches peuvent s'exécuter en parallèle
    [task_student_engagement, task_lesson_completion, task_classroom_performance] >> task_daily_report

