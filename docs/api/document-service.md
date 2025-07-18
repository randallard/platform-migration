# Document Service API

The Document Service provides secure document storage and retrieval capabilities with full encryption, audit logging, and PACER authentication integration.

## 📋 Table of Contents

- [Authentication](#authentication)
- [Base URL](#base-url)
- [Endpoints](#endpoints)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Examples](#examples)

## 🔐 Authentication

All API endpoints (except `/health`) require PACER authentication via Bearer token.

### Authentication Header
```http
Authorization: Bearer <pacer_token>
```

### PACER Token Format
The PACER token is a 128-character string obtained from the PACER OAuth 2.0 flow:
```
Authorization: Bearer a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2a3b4c5d6e7f8g9h0i1j2k3l4m5n6o7p8q9r0s1t2
```

## 🌐 Base URL

### Local Development
```
http://localhost:3000
```

### Production
```
https://documents.platform-migration.example.com
```

## 📡 Endpoints

### Health Check

#### `GET /health`
Check service health and dependencies.

**Authentication**: None required

**Response**: `200 OK`
```json
{
  "status": "healthy",
  "service": "document-service",
  "version": "0.1.0",
  "timestamp": "2025-07-18T15:30:00.000Z",
  "checks": {
    "database": {
      "status": "healthy",
      "message": "Database connection successful"
    },
    "vault": {
      "status": "healthy", 
      "message": "Vault connection successful"
    },
    "pacer": {
      "status": "healthy",
      "message": "PACER connection successful"
    }
  }
}
```

### Document Operations

#### `POST /api/v1/documents`
Upload a new document with encryption and audit logging.

**Authentication**: Required (PACER Bearer token)

**Content-Type**: `multipart/form-data`

**Request Body**:
```
Content-Type: multipart/form-data

file: [binary file data]
case_number: "2024-CV-00123"
document_type: "motion"
file_name: "motion_to_dismiss.pdf"
mime_type: "application/pdf"
is_redacted: false
retention_date: "2034-07-18T00:00:00.000Z" (optional)
```

**Response**: `201 Created`
```json
{
  "success": true,
  "data": {
    "document_id": "123e4567-e89b-12d3-a456-426614174000",
    "message": "Document uploaded successfully"
  }
}
```

**Validation Rules**:
- File size: Maximum 25MB
- File types: PDF, DOC, DOCX, TXT, RTF
- Case number format: `YYYY-TYPE-NNNNN` (e.g., `2024-CV-00123`)
- Document types: motion, order, complaint, answer, brief, etc.

#### `GET /api/v1/documents/{id}`
Retrieve a document by its ID.

**Authentication**: Required (PACER Bearer token)

**Parameters**:
- `id` (path): Document UUID

**Response**: `200 OK`
```http
Content-Type: application/pdf
Content-Disposition: attachment; filename="motion_to_dismiss.pdf"
Content-Length: 1048576

[Binary document content]
```

**Access Control**: Users can only access documents from cases they have permission to view.

#### `DELETE /api/v1/documents/{id}`
Delete a document (with audit logging).

**Authentication**: Required (PACER Bearer token)

**Parameters**:
- `id` (path): Document UUID

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "message": "Document deleted successfully",
    "document_id": "123e4567-e89b-12d3-a456-426614174000"
  }
}
```

**Note**: Deletion is logged in the audit trail and may be subject to retention policies.

#### `GET /api/v1/search`
Search documents with filtering and pagination.

**Authentication**: Required (PACER Bearer token)

**Query Parameters**:
- `case_number` (optional): Filter by case number
- `document_type` (optional): Filter by document type  
- `created_by` (optional): Filter by user who created the document
- `created_after` (optional): ISO 8601 datetime
- `created_before` (optional): ISO 8601 datetime
- `limit` (optional): Number of results (default: 20, max: 100)
- `offset` (optional): Pagination offset (default: 0)

**Example Request**:
```http
GET /api/v1/search?case_number=2024-CV-00123&document_type=motion&limit=10&offset=0
Authorization: Bearer <token>
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "documents": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "case_number": "2024-CV-00123",
        "document_type": "motion",
        "file_name": "motion_to_dismiss.pdf",
        "mime_type": "application/pdf",
        "file_size_bytes": 1048576,
        "created_at": "2025-07-18T15:30:00.000Z",
        "created_by": "user_1234",
        "last_modified": "2025-07-18T15:30:00.000Z",
        "is_redacted": false,
        "retention_date": "2034-07-18T00:00:00.000Z"
      }
    ],
    "total_count": 1,
    "has_more": false
  }
}
```

## 📊 Data Models

### Document Metadata
```typescript
interface DocumentMetadata {
  id: string;                    // UUID
  case_number: string;           // Format: YYYY-TYPE-NNNNN
  document_type: string;         // motion, order, complaint, etc.
  file_name: string;            // Original filename
  mime_type: string;            // MIME type
  file_size_bytes: number;      // File size in bytes
  created_at: string;           // ISO 8601 timestamp
  created_by: string;           // User ID
  last_modified: string;        // ISO 8601 timestamp
  is_redacted: boolean;         // Whether PII is redacted
  retention_date?: string;      // ISO 8601 timestamp (optional)
}
```

### Upload Request
```typescript
interface DocumentUploadRequest {
  case_number: string;          // Required: Case number
  document_type: string;        // Required: Document type
  file_name: string;           // Required: Original filename
  mime_type: string;           // Required: MIME type
  file_size_bytes: number;     // Required: File size
  content: Uint8Array;         // Required: File content
  is_redacted?: boolean;       // Optional: Default false
  retention_date?: string;     // Optional: ISO 8601 timestamp
}
```

### Search Request
```typescript
interface DocumentSearchRequest {
  case_number?: string;
  document_type?: string;
  created_by?: string;
  created_after?: string;      // ISO 8601 timestamp
  created_before?: string;     // ISO 8601 timestamp
  limit?: number;              // 1-100, default 20
  offset?: number;             // Default 0
}
```

### Error Response
```typescript
interface ErrorResponse {
  success: false;
  error: string;               // Human-readable error message
  code?: string;              // Machine-readable error code
  details?: object;           // Additional error details
}
```

## ⚠️ Error Handling

### HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created (document uploaded) |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid/missing token) |
| 403 | Forbidden (access denied) |
| 404 | Not Found (document not found) |
| 413 | Payload Too Large (file too big) |
| 415 | Unsupported Media Type |
| 429 | Too Many Requests (rate limited) |
| 500 | Internal Server Error |

### Error Response Format
```json
{
  "success": false,
  "error": "File too large: 30MB (max: 25MB)",
  "code": "FILE_TOO_LARGE",
  "details": {
    "actual_size": 31457280,
    "max_size": 26214400
  }
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_TOKEN` | PACER token is invalid or expired |
| `ACCESS_DENIED` | User doesn't have access to the resource |
| `VALIDATION_ERROR` | Request validation failed |
| `FILE_TOO_LARGE` | File exceeds maximum size limit |
| `UNSUPPORTED_FILE_TYPE` | File type not allowed |
| `INVALID_CASE_NUMBER` | Case number format is invalid |
| `DOCUMENT_NOT_FOUND` | Document ID doesn't exist |
| `ENCRYPTION_ERROR` | Document encryption failed |
| `STORAGE_ERROR` | Database storage error |

## 🚦 Rate Limiting

The API implements rate limiting to prevent abuse:

- **Per User**: 60 requests per minute
- **File Uploads**: 10 uploads per hour per user
- **Download Bandwidth**: 1MB/second per user

Rate limit headers are included in responses:
```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1658160600
```

When rate limited, the API returns `429 Too Many Requests`:
```json
{
  "success": false,
  "error": "Rate limit exceeded. Please wait before making more requests.",
  "code": "RATE_LIMITED",
  "details": {
    "retry_after": 15
  }
}
```

## 📝 Examples

### Upload a Document
```bash
curl -X POST http://localhost:3000/api/v1/documents \
  -H "Authorization: Bearer your-pacer-token" \
  -F "file=@motion_to_dismiss.pdf" \
  -F "case_number=2024-CV-00123" \
  -F "document_type=motion" \
  -F "file_name=motion_to_dismiss.pdf" \
  -F "mime_type=application/pdf" \
  -F "is_redacted=false"
```

### Download a Document
```bash
curl -X GET http://localhost:3000/api/v1/documents/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer your-pacer-token" \
  -o downloaded_document.pdf
```

### Search Documents
```bash
curl -X GET "http://localhost:3000/api/v1/search?case_number=2024-CV-00123&limit=10" \
  -H "Authorization: Bearer your-pacer-token"
```

### Check Health
```bash
curl -X GET http://localhost:3000/health
```

## 🔒 Security Considerations

### Data Protection
- All documents are encrypted with AES-256-GCM
- Encryption keys are managed by HashiCorp Vault
- Complete audit trail for all operations
- PII redaction support for sensitive documents

### Access Control
- PACER authentication required for all operations
- Role-based access control (RBAC)
- Case-level access permissions
- IP address logging for audit trails

### Compliance
- FISMA compliance with required security controls
- NIST SP 800-53 implementation
- Federal Rules of Civil/Criminal Procedure compliance
- Automatic PII detection and redaction warnings

## 🔧 SDKs and Integration

### JavaScript/TypeScript
```javascript
import { DocumentServiceClient } from '@platform-migration/document-service-client';

const client = new DocumentServiceClient({
  baseUrl: 'http://localhost:3000',
  token: 'your-pacer-token'
});

// Upload document
const result = await client.uploadDocument({
  file: fileBuffer,
  caseNumber: '2024-CV-00123',
  documentType: 'motion',
  fileName: 'motion.pdf',
  mimeType: 'application/pdf'
});

// Search documents
const documents = await client.searchDocuments({
  caseNumber: '2024-CV-00123',
  limit: 10
});
```

### Python
```python
from platform_migration import DocumentServiceClient

client = DocumentServiceClient(
    base_url='http://localhost:3000',
    token='your-pacer-token'
)

# Upload document
with open('motion.pdf', 'rb') as f:
    result = client.upload_document(
        file=f,
        case_number='2024-CV-00123',
        document_type='motion',
        file_name='motion.pdf',
        mime_type='application/pdf'
    )

# Search documents
documents = client.search_documents(
    case_number='2024-CV-00123',
    limit=10
)
```

## 📚 Related Documentation

- [System Architecture](../architecture/system-architecture.md)
- [Security Architecture](../architecture/security-architecture.md)
- [PACER Integration](../compliance/pacer-integration.md)
- [Audit Procedures](../compliance/audit-procedures.md)
- [Notification Service API](./notification-service.md)
- [Authentication API](./authentication.md)

---

**Need help?** Check our [troubleshooting guide](../operations/troubleshooting.md) or open an issue on [GitHub](https://github.com/randallard/platform-migration/issues).