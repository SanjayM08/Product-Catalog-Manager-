# app.py (Example Flask Application)
import oracledb
from flask import Flask, jsonify, request
import os

app = Flask(__name__)

# Database connection details from environment variables
DB_USER = os.environ.get('DB_USER')
DB_PASS = os.environ.get('DB_PASS')
DB_DSN = os.environ.get('DB_DSN')

@app.route('/api/product/<string:code>', methods=['GET'])
def get_product(code):
    try:
        connection = oracledb.connect(user=DB_USER, password=DB_PASS, dsn=DB_DSN)
        cursor = connection.cursor()

        # Call the PL/SQL function
        product_name = cursor.callfunc("product_mgr.get_product_name", oracledb.STRING, [code])

        cursor.close()
        connection.close()
        return jsonify({"code": code, "name": product_name})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)