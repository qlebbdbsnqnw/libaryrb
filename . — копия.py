from flask import Flask, request, redirect, url_for, abort, Response
from flask_sqlalchemy import SQLAlchemy
import os, uuid

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///rawhub.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10 MB

db = SQLAlchemy(app)

# -------- MODEL --------
class Raw(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    content = db.Column(db.Text)
    mime = db.Column(db.String(100), default='text/plain')

# -------- UI --------
@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        text = request.form.get('content', '')
        if not text:
            return 'Пусто', 400
        rid = str(uuid.uuid4())
        db.session.add(Raw(id=rid, content=text))
        db.session.commit()
        return redirect(url_for('view', rid=rid))

    return '''
    <!DOCTYPE html>
    <html lang="ru">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>RAW-Hub</title>
      <style>
        body { font-family: 'Arial', sans-serif; background: #0d1117; color: #c9d1d9; display: flex; flex-direction: column; align-items: center; padding: 20px; }
        h1 { color: #58a6ff; }
        textarea { width: 100%; max-width: 700px; height: 300px; background: #161b22; color: #c9d1d9; border: 1px solid #30363d; border-radius: 8px; padding: 10px; font-family: monospace; }
        button { margin-top: 10px; padding: 10px 20px; border-radius: 8px; border: none; background: #238636; color: white; cursor: pointer; font-weight: bold; }
        button:hover { background: #2ea043; }
        .footer { margin-top: 50px; color: #8b949e; font-size: 14px; }
      </style>
    </head>
    <body>
      <h1>RAW‑Hub</h1>
      <p>Создай raw‑ссылку. Она будет работать везде и без лимита.</p>
      <form method="post">
        <textarea name="content" placeholder="Вставьте сюда ваш код или текст"></textarea><br>
        <button>Создать RAW</button>
      </form>
      <div class="footer">RAW-Hub Fan-made — используй для любых проектов</div>
    </body>
    </html>
    '''

@app.route('/v/<rid>')
def view(rid):
    r = Raw.query.get_or_404(rid)
    return f'''
    <!DOCTYPE html>
    <html lang="ru">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>RAW создан</title>
      <style>
        body {{ font-family: 'Arial', sans-serif; background: #0d1117; color: #c9d1d9; display:flex; flex-direction: column; align-items: center; padding: 20px; }}
        input {{ width: 100%; max-width: 700px; padding: 10px; border-radius: 6px; border: 1px solid #30363d; margin-bottom: 20px; }}
        pre {{ background: #111; color: #0f0; padding: 15px; border-radius: 8px; width: 100%; max-width: 700px; overflow: auto; white-space: pre-wrap; word-break: break-word; }}
        h2 {{ color: #58a6ff; }}
      </style>
    </head>
    <body>
      <h2>RAW создан</h2>
      <p>Скопируйте ссылку для использования в скриптах или проектах:</p>
      <input value="{request.url_root}raw/{rid}" onclick="this.select()">
      <pre>{r.content[:2000]}</pre>
    </body>
    </html>
    '''

@app.route('/raw/<rid>')
def raw(rid):
    r = Raw.query.get_or_404(rid)
    return Response(r.content, mimetype=r.mime)

if __name__ == '__main__':
    if not os.path.exists('rawhub.db'):
        with app.app_context():
            db.create_all()
    app.run(debug=True)
