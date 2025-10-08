# 3. Use microservice architecture

Date: 2025-10-15

## Status

Accepted

Supersedes [3. Use monolithic architecture](0003-use-monolith.md)

### Context

The system requires flexibility, scalability, and ease of maintenance. Microservices architecture allows individual components to be developed, deployed, and scaled independently.

### Decision

The system will be structured as a collection of loosely coupled services (microservices), such as the web application, video system, chat system, subscription system, etc.

### Consequences

* **Positive**: Improved scalability and maintainability; each service can be deployed independently; easier to implement different technologies per service as needed.
* **Negative**: Increased complexity in service coordination and communication; potential challenges in distributed data management.