-- Table des étudiants
CREATE TABLE IF NOT EXISTS students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    classroom VARCHAR(50)
);

-- Table des leçons vidéo
CREATE TABLE IF NOT EXISTS lessons (
    lesson_id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    subject VARCHAR(100)
);

-- Table des logs de streaming (Données brutes)
CREATE TABLE IF NOT EXISTS streaming_logs (
    log_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    lesson_id INT REFERENCES lessons(lesson_id),
    watch_time_seconds INT,
    completion_percentage INT,
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de données initiales
INSERT INTO students (name, classroom) VALUES ('Mariama', 'Data_2025'), ('Boubacar', 'Data_2025');
INSERT INTO lessons (title, subject) VALUES ('Introduction à Docker', 'DevOps'), ('Maîtriser Airflow', 'Data Engineering');