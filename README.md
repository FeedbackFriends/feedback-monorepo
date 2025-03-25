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

- [Architecture Overview](./docs/architecture.md)
- [API Documentation](./docs/api_documentation.md)
- [Database Schema](./docs/database_schema.md)
- [Notification Flow](./docs/notification_flow.md)
- [Development Guide](./docs/development.md)
- [Deployment Guide](./docs/deployment.md)

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

## 📝 Contributing

Please read our [Contributing Guide](./docs/contributing.md) before submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
