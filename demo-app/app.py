from flask import Flask
import mysql.connector

app = Flask(__name__)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'app-user',
    'password': 'password',
    'database': 'demo_app'
}

def init_db():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute('CREATE TABLE IF NOT EXISTS counter (id INT PRIMARY KEY, value INT)')
    cursor.execute('SELECT COUNT(*) FROM counter')
    if cursor.fetchone()[0] == 0:
        cursor.execute('INSERT INTO counter (id, value) VALUES (1, 0)')
        conn.commit()
    cursor.close()
    conn.close()

@app.route('/')
def index():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute('SELECT value FROM counter WHERE id = 1')
    count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    
    return f'''
        <h1>Counter: {count}</h1>
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