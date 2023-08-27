import requests

print("Hello from Fargate")

r = requests.get('https://jsonplaceholder.typicode.com/todos/1')

print(r.json())