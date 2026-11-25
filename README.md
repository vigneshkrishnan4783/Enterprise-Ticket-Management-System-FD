# Enterprise Ticket Management System (FD)

A high-performance enterprise Flutter Web & Desktop application developed in accordance with the Enterprise Ticket Management System Software Requirements Specification (SRS).

---

## 🚀 Key Features & Capabilities

### 1. Web & Desktop Resolution Optimized
- **Primary Target Resolutions**: 1920×1080 (Full HD), 1440×900, 1280×800.
- **Responsive Layout**: Fluid sidebar navigation, high-density data tables, multi-column ticket investigation views, and adaptive collapse for tablets and mobile devices.

### 2. Comprehensive Role-Based Access Control (RBAC) (FR-008)
Interactive Persona Switcher in the top navigation bar to test all 7 SRS actors:
1. **External Customer** (Global Logistics Corp): Restricted to own organization's tickets, can submit public replies, request reopen, and provide 1-5★ CSAT feedback.
2. **Internal Employee / Requester** (Austin Site): Can register internal tickets with location & asset tags.
3. **Support Agent** (Core Infrastructure): Investigate tickets, update permitted statuses, publish public responses, and write private internal staff notes.
4. **Team Lead / Dispatcher**: Manage team queue, assign/reassign tickets to agents with mandatory audit justification reasons, and monitor SLA risk.
5. **Department Manager**: Department-level operational visibility, SLA breach governance, and approval controls.
6. **System Administrator**: Full configuration access for departments, support teams, categories, SLA policies, and backend connectivity.
7. **Auditor / Read-Only Analyst**: Read-only access to ticket records and chronological audit trails (cannot alter records).

### 3. Full Ticket Lifecycle Management (Section 5)
Supports all standard and exception lifecycle transitions:
`OPEN` ➔ `ASSIGNED` ➔ `IN_PROGRESS` ➔ `PENDING_CUSTOMER` ➔ `PENDING_INTERNAL` ➔ `RESOLVED` ➔ `CLOSED` ➔ `REOPENED`
- **Dynamic Priority Matrix (FR-006)**: Calculates Priority (Critical, High, Medium, Low) in real-time from a 3×3 matrix of Impact (High, Medium, Low) and Urgency (High, Medium, Low).
- **SLA Pause Rules (FR-016)**: Moving a ticket to `PENDING_CUSTOMER` requires customer question and automatically pauses the resolution SLA clock.
- **Resolution Verification (FR-019)**: Resolving a ticket requires resolution summary, code (e.g. `RES-PERMANENT-FIX`, `RES-CONFIG-CHANGE`), and root cause.
- **Customer Satisfaction (CSAT) (FR-021)**: Post-resolution 5-star rating with optional feedback comments.

### 4. Dual-Stream Communication (FR-012)
- **Public Replies**: Visible to requester and permitted support agents.
- **Internal Staff Notes**: Dedicated private tab with distinctive amber styling, strictly hidden from customers and auditors.

### 5. Chronological Audit Trail (FR-011, FR-026)
Immutable activity history recording every assignment change, status transition, old/new value, actor name/role, timestamp, and override reason.

---

## 🔌 Local Backend REST API Integration

The app includes a dedicated API integration layer (`lib/services/api_service.dart`) with:
- **Default Base URL**: `http://localhost:8080/api` (configurable in real-time).
- **Live Status Indicator**: Header pill displays connection status with ping diagnostics.
- **Graceful Fallback Mode**: If your local backend is offline or during frontend development, the system runs on an in-memory enterprise database with pre-seeded tickets, departments, comments, and audit logs.

For detailed REST endpoint schemas, see [LOCAL_BACKEND_INTEGRATION.md](file:///d:/Ticket%20System/Enterprise-Ticket-Management-System-FD/LOCAL_BACKEND_INTEGRATION.md).

---

## 💻 Running the Application

### Prerequisites
- Flutter SDK (v3.14+ / 3.50+)
- Google Chrome or Microsoft Edge

### Run in Chrome (Web Desktop)
```bash
flutter run -d chrome
```

### Run in Edge
```bash
flutter run -d edge
```

### Run as Windows Desktop Application
```bash
flutter run -d windows
```

### Build Web Release Bundle
```bash
flutter build web
```
The compiled bundle will be available in `build/web/`.
