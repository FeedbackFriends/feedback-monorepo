# Feedback Backend

[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.0.0-green.svg)](https://github.com/FeedbackFriends/feedback-openapi/blob/main/openapi.yaml)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.0-blue.svg)](https://kotlinlang.org)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)

A Spring Boot application powering the LetsGrow feedback platform. Provides REST APIs and background processing for
feedback management and notifications.

## 🚀 Quick Start

1. Clone the repository
2. Set up environment variables (see `.env.example`)
3. Run with Docker:
   ```bash
   docker-compose up
   ```
   Or locally:
   ```bash
   ./gradlew bootRun
   ```

## 📚 Documentation

All technical documentation is in the [`docs/`](./docs/) folder. Start here:

- [Architecture Overview](./docs/architecture.md) – System structure, main flows, and tech stack.
- [Development Guide](./docs/development.md) – Local setup, project structure, and dev tasks.
- [Deployment Guide](./docs/deployment.md) – How to deploy and required configuration.
- [Contributing Guide](./docs/contributing.md) – How to contribute and code standards.
- [Database Schema (ERD)](./docs/diagrams/database.puml) – Entity-relationship diagram of the database (PlantUML).
- [Notification Flow](./docs/diagrams/notification_flow.puml) – How notifications and scheduling work.
- [All Diagrams](./docs/diagrams/) – More PlantUML diagrams for architecture, flows, and models.

## 🔍 API Reference

The API is documented using OpenAPI 3.0.0 specification:

- [OpenAPI Specification](https://github.com/FeedbackFriends/feedback-openapi/blob/main/openapi.yaml)
- [Interactive API Documentation](https://editor.swagger.io/?url=https://raw.githubusercontent.com/FeedbackFriends/feedback-openapi/main/openapi.yaml)

## 🛠️ Development

- Built with Kotlin + Spring Boot
- PostgreSQL database with Exposed ORM
- Firebase for auth and notifications
- Automated CI/CD with Github Actions

For detailed setup and development guidelines, see [Development Guide](./docs/development.md)
