# Add --platform=linux/amd64 option if running on ARM architecture (e.g. M1 mac)
FROM python:3 

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "python", "./main.py" ]






