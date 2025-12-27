# builder
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --no-cache-dir --prefix=/install -r requirements.txt

# runtime
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY app.py .

EXPOSE 8080
CMD ["python", "app.py"]

