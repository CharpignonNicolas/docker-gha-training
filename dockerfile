# Étape 1 : Builder pour réduire l'image finale
FROM python:3-slim as builder

WORKDIR /app

# Copie et installation sécurisée des dépendances (en tant que non-root)
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip wheel --no-cache-dir -r requirements.txt -w /wheels

# Étape 2 : Image finale légère
FROM python:3-slim

# Création d'un utilisateur non-root
RUN useradd -m appuser

WORKDIR /app

# Copier uniquement ce qui est nécessaire
COPY --from=builder /wheels /wheels
COPY requirements.txt .
COPY . .

# Installation des dépendances à partir des wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt

# Utiliser l'utilisateur non-root
USER appuser

# Port exposé par l’application (ex. Flask)
EXPOSE 5000

# Commande de lancement (à adapter si tu n’utilises pas Flask)
CMD ["python", "app/main.py"]