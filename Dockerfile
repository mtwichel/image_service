# Multi-stage Dockerfile for Image Service
# Stage 1: Build the application
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files first for better layer caching
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN dart pub get

# Copy source code
COPY . .

# Install dart_frog_cli globally
RUN dart pub global activate dart_frog_cli

# Generate production build
RUN dart pub global run dart_frog_cli:dart_frog build

# Compile the application to native executable
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Create data directory structure with proper ownership for non-root user
RUN mkdir -p /app/data/images && chown -R 65534:65534 /app/data

# Stage 2: Create minimal runtime image from scratch
FROM scratch

# Copy minimal runtime dependencies from Dart SDK
# This includes the necessary C libraries that the compiled binary needs
COPY --from=build /runtime/ /

# Copy the compiled binary
COPY --from=build /app/build/bin/server /app/bin/server

# Copy static assets
COPY --from=build /app/build/public /public/

# Copy data directory structure with proper ownership
# This creates /app/data/images owned by user 65534 for writable volume mount
COPY --from=build --chown=65534:65534 /app/data /app/data

# Use numeric UID/GID for non-root user (nobody = 65534)
# This works even in scratch without useradd
USER 65534:65534

# Expose port
EXPOSE 8080


# Add labels for better container management
LABEL org.opencontainers.image.title="Image Service"
LABEL org.opencontainers.image.description="High-performance image storage and serving service built with Dart Frog"
LABEL org.opencontainers.image.vendor="Marcus Twichel"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.security="Minimal attack surface with scratch base image and non-root user"

# Start the server
CMD ["/app/bin/server"]
