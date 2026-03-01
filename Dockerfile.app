FROM node:20-bookworm-slim

# Install Xvfb, Chrome dependencies, and other system packages
RUN apt-get update && apt-get install -y \
    xvfb \
    libnss3 \
    libasound2 \
    libgbm-dev \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libglib2.0-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libxcb1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    wget \
    chromium \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files first for layer caching
COPY package.json package-lock.json* ./

# Install Node dependencies (skip puppeteer's bundled Chrome download, use system chromium)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN npm install

# Copy the rest of the application
COPY . .

# Ensure user_data directory exists
RUN mkdir -p user_data

EXPOSE 58082

# Start Xvfb on display :99 then launch the Node server
# The target argument is passed via CMD override: docker run ... node_image target_name
ENTRYPOINT ["/bin/sh", "-c", "Xvfb :99 -screen 0 2880x1800x24 -ac & sleep 1 && DISPLAY=:99 node index.js \"$@\"", "--"]
