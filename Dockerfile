FROM python:3.11-slim

# Install Node.js (for Bun) and system deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip git && \
    rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Install Jac dependencies and validate
RUN jac install && jac check main.jac

# UI on 8000, API on 8001
EXPOSE 8000 8001

CMD ["jac", "start", "main.jac"]
