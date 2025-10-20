Thanks for contributing! This serves as a guideline for how to effectively contribute to the project.

## Proposing Changes

If you intend to change the public API, or make any non-trivial changes to the implementation, we recommend filing an issue. This lets us reach an agreement on your proposal before you put significant effort into it.

If you're only fixing a bug, it's fine to submit a pull request right away but we still recommend to file an issue detailing what you're fixing. This is helpful in case we don't accept that specific fix but want to keep track of the issue.

## Creating a Pull Request

Before creating a pull request please:

1. Fork the repository and create your branch from main.
2. Install all dependencies (`dart pub get`).
3. Squash your commits and ensure you have a meaningful commit message.
4. If you've fixed a bug or added code that should be tested, add tests!
5. Ensure the test suite passes.
6. If you've changed the public API, make sure to update/add documentation.
7. Format your code (dart format .).
8. Analyze your code (dart analyze --fatal-infos --fatal-warnings .).
9. Create the Pull Request.
10. Verify that all status checks are passing.
    While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

## Running Locally

### 1. Clone the Repository

```bash
git clone <repository-url>
cd image_service
```

### 2. Install Dependencies

```bash
dart pub get
```

### 3. Install Dart Frog CLI

The project uses Dart Frog as the web framework. Install the CLI globally:

```bash
dart pub global activate dart_frog_cli
```

Make sure the Dart global bin directory is in your PATH. If not, add it:

```bash
# For macOS/Linux, add to your ~/.bashrc, ~/.zshrc, or equivalent
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 4. Set Up Environment Variables

Create a `.env` file or set environment variables:

```bash
# Required: API key for authentication
export SECRET_KEY=your-secret-api-key-here

# Optional: Base URL for generating public URLs in dashboard (default: http://localhost:8080)
export BASE_URL=https://your-domain.com

# Optional: Cache time in seconds (default: 604800 = 7 days)
export CACHE_TIME=604800
```

**Important:** Keep your `SECRET_KEY` secure and never commit it to version control.

### 5. Create Data Directory

The service stores images in a local directory:

```bash
mkdir -p data/images
```

## Running the Service

### Development Mode

Run the service in development mode with hot reload:

```bash
dart_frog dev
```

The service will be available at `http://localhost:8080`

### Production Mode

Build and run in production mode:

```bash
# Build the application
dart_frog build

# Run the compiled server
dart run build/bin/server.dart
```

## Project Structure

```
image_service/
├── main.dart                     # Entry point for Dart Frog server
├── routes/                       # API routes (dynamic routing)
│   ├── _middleware.dart         # CORS, logging, caching middleware
│   ├── dashboard/               # Web dashboard endpoints
│   ├── files/                   # Image serving & transformation
│   └── upload-tokens/           # Temporary upload URL endpoints
├── lib/                         # Core business logic
│   └── src/
│       ├── metadata.dart        # Image metadata & storage
│       ├── image_upload_utils.dart
│       └── temporary_upload_token_store.dart
├── image_service_client/        # Official Dart client SDK
│   ├── lib/
│   │   └── src/
│   │       ├── image_service_client.dart
│   │       └── models/          # Shared models (ImageMetadata, etc.)
│   ├── test/                    # Client SDK tests
│   ├── pubspec.yaml
│   └── README.md
├── public/                      # Static assets (CSS, JS for dashboard)
├── data/                        # Runtime data (git-ignored)
│   ├── images/                  # Image storage
│   └── metadata/                # Hive database files
├── test/                        # Server tests
├── Dockerfile                   # Production Docker image
├── pubspec.yaml                 # Server dependencies
└── README.md                    # This file
```

## Testing

Run the test suite:

```bash
dart test
```

Run tests with coverage:

```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

## Development

### Code Quality

This project uses `very_good_analysis` for linting. Run analysis:

```bash
dart analyze
```

### Hot Reload

When running in development mode (`dart_frog dev`), the service automatically reloads on file changes.
