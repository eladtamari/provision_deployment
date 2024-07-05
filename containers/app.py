# # app.py
# from flask import Flask, jsonify
# import random

# app = Flask(__name__)

# quotes = [
#     "The only way to do great work is to love what you do. - Steve Jobs",
#     "Believe you can and you're halfway there. - Theodore Roosevelt",
#     "I have not failed. I've just found 10,000 ways that won't work. - Thomas Edison",
#     "If you look at what you have in life, you'll always have more. - Oprah Winfrey",
#     "If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success. - James Cameron"
# ]

# @app.route('/quote')
# def get_quote():
#     quote = random.choice(quotes)
#     return jsonify({'quote': quote})

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, This is a simple Python App!"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')