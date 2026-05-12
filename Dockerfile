FROM python:3.11-slim

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ffmpeg \
    ripgrep \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Copy repo contents
COPY . .

# Install uv (fast Python package manager)
RUN pip install uv

# Install Hermes and all its dependencies
RUN uv pip install --system -e .

# Create persistent data directory
RUN mkdir -p /data/.hermes

# Point Hermes at the persistent disk
ENV HERMES_HOME=/data/.hermes
ENV PYTHONUNBUFFERED=1

# Render injects $PORT — default to 8000
ENV PORT=8000

EXPOSE 8000

# Write a startup script so logic is readable and easy to debug
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
