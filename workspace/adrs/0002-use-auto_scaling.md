# 2. Use Auto-scaling for video processing

Date: 2025-10-13

## Status

Accepted

## Context

We require dynamic scaling of the video processors to handle adaptive bitrate and resolution requirements. This will ensure that the video processing service can handle varying loads efficiently.

## Decision

The video processors component will be configured to use auto-scaling. This involves setting up scaling policies based on CPU usage and network traffic.

## Consequences

* **Positive**: The system can automatically scale its resources to match the load, ensuring high availability and performance during peak traffic.
* **Negative**: Additional complexity in monitoring and managing scaling policies; potential cost implications due to scaling.