# Contributing to Platform Migration

Welcome! We're excited that you're interested in contributing to the Platform Migration project. This guide will help you get started with contributing to our secure document storage and notification system.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)
- [Security](#security)
- [Getting Help](#getting-help)

## 🤝 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites

- **Rust**: Latest stable version
- **Docker/Rancher Desktop**: With WebAssembly support
- **Nix**: With flakes enabled (recommended)
- **Git**: For version control
- **kubectl**: For Kubernetes development

### Quick Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/platform-migration.git
   cd platform-migration
   ```

2. **Setup development environment**
   ```bash
   # Using Nix (recommended)
   nix develop
   
   # Or using direnv
   direnv allow
   ```

3. **Start local infrastructure**
   ```bash
   ./scripts/local-dev/start-infrastructure.sh
   ```

4. **Run tests**
   ```bash
   ./scripts/test/run-all-tests.sh
   ```

## 🛠️ Development Setup

### Environment Setup

1. **Install Rust tools**
   ```bash
   # Install required Rust tools
   rustup target add wasm32-wasip1
   cargo install cargo-component
   cargo install sqlx-cli
   ```

2. **Install Spin CLI**
   ```bash
   # Install Spin CLI for WebAssembly development
   curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
   ```

3. **Setup pre-commit hooks**
   ```bash
   # Install pre-commit hooks
   pre-commit install
   ```

### IDE Configuration

#### VS Code
```json
{
  "rust-analyzer.cargo.features": "all",
  "rust-analyzer.checkOnSave.command": "clippy",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

#### Vim/Neovim
```lua
-- Add to your config
require('lspconfig').rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})
```

## 📝 Contributing Guidelines

### Types of Contributions

We welcome several types of contributions:

- **🐛 Bug Reports**: Help us identify and fix issues
- **✨ Feature Requests**: Suggest new functionality
- **📖 Documentation**: Improve or add documentation
- **🧪 Tests**: Add or improve test coverage
- **🔧 Code**: Fix bugs or implement features
- **🔍 Security**: Report security vulnerabilities

### Before You Start

1. **Check existing issues**: Look for existing issues or discussions
2. **Create an issue**: For new features or significant changes
3. **Discuss design**: Get feedback on your approach
4. **Start small**: Begin with small, focused changes

### Branching Strategy

- **main**: Stable, production-ready code
- **develop**: Integration branch for features
- **feature/***: Feature development branches
- **hotfix/***: Critical bug fixes
- **release/***: Release preparation branches

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or fixing tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(document-service): add document encryption

Implement AES-256-GCM encryption for document storage
with envelope encryption pattern using Vault for key management.

Closes #123
```

```
fix(auth): handle PACER token expiration

Fix issue where expired PACER tokens were not being
refreshed automatically, causing authentication failures.

Fixes #456
```

## 🔄 Pull Request Process

### Before Creating a PR

1. **Update your fork**
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the code style guide
   - Add tests for new functionality
   - Update documentation as needed

4. **Test your changes**
   ```bash
   # Run all tests
   ./scripts/test/run-all-tests.sh
   
   # Run specific service tests
   cd services/document-service
   cargo test
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(scope): your feature description"
   ```

### Creating the Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**
   - Use the PR template
   - Provide clear description
   - Link related issues
   - Add appropriate labels

3. **PR Template**
   ```markdown
   ## Description
   Brief description of the changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] All tests pass
   - [ ] New tests added
   - [ ] Manual testing completed
   
   ## Security
   - [ ] No sensitive data exposed
   - [ ] Security review completed
   - [ ] Compliance requirements met
   
   ## Checklist
   - [ ] Code follows style guide
   - [ ] Documentation updated
   - [ ] Changelog updated
   ```

### Review Process

1. **Automated Checks**
   - Tests must pass
   - Code style checks
   - Security scans
   - Build verification

2. **Manual Review**
   - Code quality review
   - Security review
   - Architecture review
   - Documentation review

3. **Approval Requirements**
   - At least 1 approval for minor changes
   - At least 2 approvals for major changes
   - Security team approval (for security changes)
   - Maintainer approval

## 🎨 Code Style

### Rust Code Style

#### Formatting
```bash
# Format all code
cargo fmt

# Check formatting
cargo fmt --check
```

#### Linting
```bash
# Run Clippy
cargo clippy -- -D warnings

# Run with all features
cargo clippy --all-features -- -D warnings
```

#### Code Structure
```rust
// Example: Well-structured Rust code
use std::collections::HashMap;
use anyhow::{Result, anyhow};
use serde::{Deserialize, Serialize};

/// Document service for secure document storage
/// 
/// This service handles document upload, retrieval, and management
/// with full encryption and audit logging.
#[derive(Debug, Clone)]
pub struct DocumentService {
    database: Arc<Database>,
    crypto: Arc<CryptoService>,
    config: ServiceConfig,
}

impl DocumentService {
    /// Create a new document service instance
    pub fn new(
        database: Arc<Database>,
        crypto: Arc<CryptoService>,
        config: ServiceConfig,
    ) -> Self {
        Self {
            database,
            crypto,
            config,
        }
    }
    
    /// Upload a document with encryption and audit logging
    pub async fn upload_document(
        &self,
        request: UploadRequest,
        user_id: &str,
    ) -> Result<DocumentId> {
        // Validate request
        self.validate_upload_request(&request)?;
        
        // Encrypt document
        let encrypted_doc = self.crypto
            .encrypt_document(&request.content)
            .await?;
        
        // Store in database
        let doc_id = self.database
            .store_document(encrypted_doc, user_id)
            .await?;
        
        // Log access
        self.log_document_access(doc_id, user_id, "UPLOAD")
            .await?;
        
        Ok(doc_id)
    }
}
```

### Documentation Standards

#### Rust Documentation
```rust
/// Encrypts a document using AES-256-GCM with envelope encryption
/// 
/// # Arguments
/// 
/// * `content` - The document content to encrypt
/// * `key_id` - The encryption key identifier
/// 
/// # Returns
/// 
/// Returns an `EncryptedDocument` containing the encrypted content,
/// nonce, and key reference.
/// 
/// # Errors
/// 
/// This function will return an error if:
/// * The encryption key cannot be retrieved from Vault
/// * The encryption operation fails
/// * The content is empty or too large
/// 
/// # Examples
/// 
/// ```
/// use document_service::crypto::encrypt_document;
/// 
/// let content = b"This is a test document";
/// let encrypted = encrypt_document(content, "key-123").await?;
/// ```
pub async fn encrypt_document(
    content: &[u8],
    key_id: &str,
) -> Result<EncryptedDocument, EncryptionError> {
    // Implementation
}
```

## 🧪 Testing

### Test Structure

```
services/document-service/
├── src/
│   ├── lib.rs
│   ├── handlers/
│   └── ...
├── tests/
│   ├── integration/
│   │   ├── document_upload_test.rs
│   │   └── pacer_auth_test.rs
│   └── common/
│       └── mod.rs
└── Cargo.toml
```

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use tokio_test;
    
    #[tokio::test]
    async fn test_document_encryption() {
        let content = b"test document content";
        let key_id = "test-key-123";
        
        let encrypted = encrypt_document(content, key_id).await
            .expect("Encryption should succeed");
        
        assert!(!encrypted.content.is_empty());
        assert_eq!(encrypted.key_id, key_id);
    }
    
    #[test]
    fn test_case_number_validation() {
        let valid_cases = vec![
            "2024-CV-00123",
            "2023-CR-99999",
            "2024-BK-12345",
        ];
        
        for case in valid_cases {
            assert!(is_valid_case_number(case), 
                "Case number {} should be valid", case);
        }
    }
}
```

### Integration Tests
```rust
// tests/integration/document_upload_test.rs
use document_service::*;
use tokio_test;

#[tokio::test]
async fn test_complete_document_upload_flow() {
    // Setup test environment
    let config = TestConfig::default();
    let service = DocumentService::new_for_test(config).await;
    
    // Create test document
    let document = TestDocument::new()
        .with_content(b"Test document content")
        .with_case_number("2024-CV-00123")
        .with_type("motion");
    
    // Upload document
    let result = service.upload_document(document, "test-user").await;
    
    // Verify upload
    assert!(result.is_ok());
    let doc_id = result.unwrap();
    
    // Verify document can be retrieved
    let retrieved = service.get_document(doc_id, "test-user").await;
    assert!(retrieved.is_ok());
    
    // Verify audit log
    let audit_logs = service.get_audit_logs(doc_id).await.unwrap();
    assert_eq!(audit_logs.len(), 2); // UPLOAD and RETRIEVE
}
```

### Test Commands
```bash
# Run all tests
cargo test

# Run specific test
cargo test test_document_encryption

# Run with coverage
cargo tarpaulin --out html

# Run integration tests
cargo test --test integration

# Run with logging
RUST_LOG=debug cargo test
```

## 📚 Documentation

### Documentation Types

1. **Code Documentation**: Inline Rust docs
2. **API Documentation**: OpenAPI/Swagger specs
3. **Architecture Documentation**: Design decisions
4. **User Documentation**: How-to guides
5. **Compliance Documentation**: Security controls

### Writing Documentation

#### Markdown Standards
```markdown
# Page Title

Brief description of the page content.

## Section Title

### Subsection Title

Content with proper formatting:

- Use bullet points for lists
- Use `code` formatting for technical terms
- Use **bold** for important concepts
- Use *italic* for emphasis

#### Code Examples

```rust
// Always include comments in code examples
let result = function_call(parameter);
```

#### Important Notes

> **Note**: Use blockquotes for important information

⚠️ **Warning**: Use warning symbols for critical information

✅ **Success**: Use checkmarks for completed items
```

## 🔒 Security

### Security Guidelines

1. **Never commit secrets**
   - Use environment variables
   - Use Vault for secrets
   - Review commits before pushing

2. **Input validation**
   - Validate all user inputs
   - Sanitize file uploads
   - Use parameterized queries

3. **Error handling**
   - Don't expose sensitive information
   - Log security events
   - Use generic error messages

4. **Dependencies**
   - Keep dependencies updated
   - Run security audits
   - Review new dependencies

### Security Review Process

1. **Automated Scanning**
   ```bash
   # Run security audit
   cargo audit
   
   # Check for vulnerabilities
   cargo deny check
   ```

2. **Manual Review**
   - Code review by security team
   - Architecture review
   - Compliance verification

3. **Reporting Security Issues**
   - Email: security@platform-migration.example.com
   - Use GitHub Security Advisories
   - Follow responsible disclosure

## 🆘 Getting Help

### Resources

- **Documentation**: [docs/](./docs/) folder
- **Issues**: [GitHub Issues](https://github.com/randallard/platform-migration/issues)
- **Discussions**: [GitHub Discussions](https://github.com/randallard/platform-migration/discussions)

### How to Ask for Help

1. **Search first**: Check existing issues and documentation
2. **Be specific**: Provide detailed description and context
3. **Include examples**: Code snippets, error messages, logs
4. **Be patient**: Maintainers are volunteers

### Issue Templates

```markdown
## Bug Report

**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Environment**
- OS: [e.g. Ubuntu 22.04]
- Rust version: [e.g. 1.70.0]
- Service version: [e.g. v0.1.0]

**Additional context**
Any other context about the problem.
```

## 📄 License

By contributing to Platform Migration, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

All contributors will be recognized in our [CONTRIBUTORS.md](./CONTRIBUTORS.md) file and in release notes.

---

**Thank you for contributing to Platform Migration!** 🎉

Your contributions help make secure document storage and federal compliance more accessible to everyone.