from flask import Flask
import mysql.connector
import os
import time
import redis

app = Flask(__name__)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'mysql'),
    'user': os.getenv('DB_USER', 'app-user'),
    'password': os.getenv('DB_PASSWORD', 'password'),
    'database': os.getenv('DB_NAME', 'demo_app')
}

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=6379,
    decode_responses=True
)

def init_db():
    for i in range(10):
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            cursor = conn.cursor()
            cursor.execute('CREATE TABLE IF NOT EXISTS counter (id INT PRIMARY KEY, value INT)')
            cursor.execute('SELECT COUNT(*) FROM counter')
            if cursor.fetchone()[0] == 0:
                cursor.execute('INSERT INTO counter (id, value) VALUES (1, 0)')
                conn.commit()
            cursor.close()
            conn.close()
            print("Database initialized")
            return
        except Exception as e:
            print("Waiting for DB...", e)
            time.sleep(2)

    raise Exception("Database not ready")


@app.route('/')
def index():
    visits = redis_client.incr("visits")

    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute('SELECT value FROM counter WHERE id = 1')
    count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    
    return f'''
        <h1>Counter: {count}</h1>
        <h2>Visits: {visits}</h2>
        <form action="/increment" method="post">
            <button type="submit">+1</button>
        </form>
    '''

@app.route('/increment', methods=['POST'])
def increment():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute('UPDATE counter SET value = value + 1 WHERE id = 1')
    conn.commit()
    cursor.close()
    conn.close()
    return index()

if __name__ == '__main__':
    init_db()
    app.run(debug=True, host='0.0.0.0', port=8080)
