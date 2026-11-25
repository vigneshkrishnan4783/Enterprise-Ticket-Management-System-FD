# Local Backend REST API Integration Guide

This document specifies the REST API endpoints and JSON request/response formats expected by the **Enterprise Ticket Management System (FD)** frontend.

---

## ⚙️ Configuration

The frontend is pre-configured with a default base URL:
```text
http://localhost:8080/api
```

You can change this URL at runtime:
1. Click the **API Status Indicator** in the top navigation bar.
2. Enter your backend URL (e.g., `http://localhost:5000/api` or `http://127.0.0.1:8000/api`).
3. Click **Test Connection & Save**.

---

## 📡 REST API Endpoints Specification

### 1. Health Check
- **Endpoint**: `GET /health`
- **Response** (`200 OK`):
  ```json
  {
    "status": "UP",
    "timestamp": "2026-11-24T18:00:00Z"
  }
  ```

---

### 2. Tickets List
- **Endpoint**: `GET /tickets`
- **Query Parameters**:
  - `status` (e.g. `open`, `assigned`, `inProgress`, `pendingCustomer`, `resolved`, `closed`)
  - `priority` (e.g. `critical`, `high`, `medium`, `low`)
  - `departmentId` (e.g. `dept-it`)
  - `q` (free-text search string)
- **Response** (`200 OK`):
  ```json
  [
    {
      "id": "tick-001",
      "ticketNumber": "TIC-2026-00101",
      "subject": "Critical Production DB cluster failover latency spike",
      "description": "Primary PostgreSQL cluster replica node experienced degraded heartbeat...",
      "category": "Infrastructure",
      "subcategory": "Database Services",
      "impact": "high",
      "urgency": "high",
      "priority": "critical",
      "status": "inProgress",
      "requesterId": "usr-cust-01",
      "requesterName": "Global Logistics Corp (Client)",
      "requesterEmail": "ops@globallogistics.com",
      "requesterOrg": "Global Logistics Corp",
      "assigneeId": "agent-alex",
      "assigneeName": "Alex Miller",
      "supportTeamId": "team-infra",
      "supportTeamName": "Core Infrastructure",
      "departmentId": "dept-it",
      "departmentName": "Information Technology",
      "siteLocation": "East Coast DC - Pod 4",
      "assetDetails": "Cluster-PG-PROD-01",
      "createdAt": "2026-11-24T17:15:00Z",
      "updatedAt": "2026-11-24T17:50:00Z",
      "firstResponseAt": "2026-11-24T17:22:00Z",
      "firstResponseDeadline": "2026-11-24T17:30:00Z",
      "resolutionDeadline": "2026-11-24T19:15:00Z",
      "isResponseSlaBreached": false,
      "isResolutionSlaBreached": false,
      "slaPausedDurationMinutes": 0,
      "isSlaCurrentlyPaused": false
    }
  ]
  ```

---

### 3. Create Ticket (FR-002, FR-003)
- **Endpoint**: `POST /tickets`
- **Request Body**:
  ```json
  {
    "subject": "VPN Gateway authentication failure",
    "description": "Remote users unable to connect to subnet gateway.",
    "category": "Networking",
    "subcategory": "VPN & Remote Access",
    "impact": "high",
    "urgency": "medium",
    "departmentId": "dept-it",
    "requesterId": "usr-emp-01",
    "requesterName": "Rachel Adams",
    "requesterEmail": "rachel.adams@enterprise.org",
    "requesterOrg": "Enterprise Internal - Austin Site",
    "siteLocation": "Austin Innovation Center",
    "assetDetails": "GW-VPN-AUS-02"
  }
  ```
- **Response** (`201 Created`): Returns created Ticket object with generated `ticketNumber` (e.g. `TIC-2026-00107`) and computed SLA deadlines.

---

### 4. Status Transition (FR-019, FR-020)
- **Endpoint**: `PUT /tickets/:id/status`
- **Request Body**:
  ```json
  {
    "status": "resolved",
    "actorId": "agent-alex",
    "actorRole": "supportAgent",
    "reason": "Service restored and verified",
    "resolutionSummary": "Updated TLS certificate on gateway cluster",
    "resolutionCode": "RES-CONFIG-CHANGE",
    "rootCause": "Annual certificate rollover",
    "customerQuestion": null,
    "dependentTeam": null
  }
  ```
- **Response** (`200 OK`): Returns updated Ticket object.

---

### 5. Ticket Assignment (FR-009, FR-011)
- **Endpoint**: `PUT /tickets/:id/assign`
- **Request Body**:
  ```json
  {
    "teamId": "team-infra",
    "teamName": "Core Infrastructure",
    "agentId": "agent-alex",
    "agentName": "Alex Miller",
    "actorId": "lead-sarah",
    "reason": "Subject matter expert for high-availability database cluster"
  }
  ```
- **Response** (`200 OK`): Returns updated Ticket object.

---

### 6. Comments & Notes (FR-012)
- **Endpoint**: `GET /tickets/:id/comments`
- **Response** (`200 OK`): List of comments.
- **Endpoint**: `POST /tickets/:id/comments`
- **Request Body**:
  ```json
  {
    "content": "Standby replica promoted to primary node.",
    "isInternal": true,
    "authorId": "agent-alex",
    "authorName": "Alex Miller",
    "authorRole": "supportAgent",
    "attachments": []
  }
  ```
- **Response** (`201 Created`): Returns created TicketComment object.

---

### 7. CSAT Feedback (FR-021)
- **Endpoint**: `POST /tickets/:id/feedback`
- **Request Body**:
  ```json
  {
    "rating": 5,
    "feedback": "Fast response and resolved without disruption.",
    "requesterId": "usr-cust-01"
  }
  ```
- **Response** (`200 OK`): Returns updated Ticket with feedback recorded.

---

### 8. Departments & Teams
- **Endpoint**: `GET /departments`
- **Response** (`200 OK`): List of departments and support teams.
