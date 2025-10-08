# 7. Use Auth0 for authentication 

Date: 2025-10-13
## Status

Accepted

### Context

**StageCast** requires externalized authentication as part of its MVP. This includes:

* Viewer and streamer login and registration
* Secure token issuance and validation
* Role-based access control (e.g., VIP streamers)
* Integration with frontend (WebApp) and backend API

We evaluated the following options:

1. Amazon Cognito

    * Fully managed and integrated with AWS
    * Low cost, especially in early stages
    * Difficult to customize login flows and UI
    * Debugging and configuration are opaque

2. Auth0
   * Hosted identity platform with rich feature set
   * Easy integration with SDKs and OIDC support
   * Supports social login, custom rules, branding
   * Excellent documentation and developer UX
   * SaaS pricing may increase with scale

3. Keycloak
   * Open source, customizable, no vendor lock-in
   * Strong support for enterprise protocols
   * High operational burden for self-hosting
   * Requires DevOps capacity we don’t currently have

### Decision

We will use Auth0 for authentication in the MVP.

* It enables rapid delivery with low effort
* It provides secure, standards-compliant authentication
* It integrates well with AWS-based infrastructure
* It reduces operational overhead for the team
* It allows us to iterate quickly on login flows and auth rules

### Consequences

* We rely on a SaaS provider for identity, introducing potential vendor lock-in
* Monthly costs may rise with user volume and features
* Migration to self-hosted solutions (e.g., Keycloak) may require effort later
* We must design an abstraction (Auth Adapter) so the backend is loosely coupled to Auth0 APIs

### Next Steps

1. Implement Auth0 tenant and user pool configuration
2. Integrate with WebApp for login/logout and callback handling
3. Implement token validation and role extraction in the Backend API
4. Capture usage metrics and monitor SaaS limits