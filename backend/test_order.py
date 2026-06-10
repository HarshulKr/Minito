import requests

data = {
    "customer_id": 1,
    "total": 50,
    "items": [{"product_id": 1, "qty": 1}]
}

try:
    res = requests.post("http://localhost:5000/order/create", json=data)
    print("Status Code:", res.status_code)
    print("Response JSON:", res.json())
except Exception as e:
    print(e)
