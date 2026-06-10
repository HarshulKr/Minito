from flask import Flask
from flask_cors import CORS

from routes.auth import auth
from routes.customer import customer
from routes.order import order
from routes.admin import admin
from routes.manager import manager
from routes.delivery import delivery


app = Flask(__name__)
CORS(app)

app.register_blueprint(auth, url_prefix="/auth")
app.register_blueprint(customer, url_prefix="/customer")
app.register_blueprint(order, url_prefix="/order")
app.register_blueprint(admin, url_prefix="/admin")
app.register_blueprint(manager, url_prefix="/manager")
app.register_blueprint(delivery, url_prefix="/delivery")

@app.route("/")
def home():
    return {"message": "Minito backend running"}

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)