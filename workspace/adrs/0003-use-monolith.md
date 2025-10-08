# 3. Use monolithic architecture

Date: 2025-10-13

## Status

Superceded by [8. Use Microservices](0008-use-microservices.md))

### Context

The system is designed to handle various functionalities such as user management, content creation, real-time communication, and subscription management. Each of these functionalities can be developed and deployed as a Monolith service.

### Decision

We will use a monolithic architecture for the system. This means that all functionalities will be developed and deployed as a single, unified application. This approach simplifies deployment and management but may limit scalability and maintainability in the long run.

### Consequences

 **Pros:** low cognitive load
 ** Cons:**:** Hard to escale