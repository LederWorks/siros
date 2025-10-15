# Contributing to Siros

Thank you for your interest in contributing to Siros! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Go 1.24 or higher
- Node.js 18+ and npm
- PostgreSQL 15+ with pgvector extension
- Docker (optional, for database)

### Development Setup

1. **Fork and clone the repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/siros.git
   cd siros
   ```

2. **Set up the development environment**

   ```bash
   # Start development servers (hot reload)
   ./scripts/dev.sh

   # Or build production version
   ./scripts/build_all.sh
   ```

3. **Run tests**

   ```bash
   # Backend tests
   cd backend && go test ./...

   # Frontend tests
   cd frontend && npm test
   ```

## 📋 How to Contribute

### Reporting Issues

Before creating an issue, please:

1. Search existing issues to avoid duplicates
2. Use the appropriate issue template
3. Provide detailed information including:
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details
   - Screenshots (if applicable)

### Submitting Pull Requests

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the coding guidelines below
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**

   ```bash
   # Run all tests
   ./scripts/test.sh

   # Build and test integration
   ./scripts/build_all.sh
   ```

4. **Commit your changes**

   ```bash
   git commit -m "feat: add your feature description"
   ```

5. **Push and create a PR**

   ```bash
   git push origin feature/your-feature-name
   ```

## 🎯 Coding Guidelines

### General Principles

- Write clean, readable, and maintainable code
- Follow established patterns in the codebase
- Add appropriate tests for new functionality
- Update documentation for API changes

### Backend (Go)

- Follow standard Go conventions and use `gofmt`
- Use meaningful variable and function names
- Handle errors appropriately with context
- Add comprehensive unit tests
- Use interfaces for dependency injection

### Frontend (React + TypeScript)

- Use functional components with hooks
- Follow TypeScript best practices
- Create reusable components
- Ensure responsive design
- Add proper error handling

### Git Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:

```
feat(api): add semantic search endpoint
fix(frontend): resolve resource list pagination issue
docs: update API documentation for new endpoints
```

## 🧪 Testing Guidelines

### Backend Testing

- Write unit tests for all business logic
- Use table-driven tests where appropriate
- Mock external dependencies
- Test error conditions and edge cases

```go
func TestResourceService_CreateResource(t *testing.T) {
    tests := []struct {
        name    string
        request CreateResourceRequest
        want    *Resource
        wantErr bool
    }{
        // Test cases
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

### Frontend Testing

- Test component behavior, not implementation details
- Use React Testing Library
- Mock API calls
- Test accessibility features

```tsx
test('displays resource information correctly', () => {
  const mockResource = { id: '1', name: 'Test Resource' };
  render(<ResourceCard resource={mockResource} />);

  expect(screen.getByRole('heading', { name: 'Test Resource' })).toBeInTheDocument();
});
```

## 📚 Documentation

When contributing, please ensure:

- API changes are documented
- New features include usage examples
- README is updated if needed
- Code comments explain complex logic

## 🔍 Code Review Process

1. All PRs require review from maintainers
2. Automated checks must pass (CI/CD, tests, linting)
3. Address review feedback promptly
4. Keep PRs focused and reasonably sized
5. Maintain a professional and constructive tone

## 🏷️ Issue and PR Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Documentation improvements
- `good-first-issue`: Good for newcomers
- `help-wanted`: Community help needed
- `security`: Security-related issues
- `backend`: Backend-related changes
- `frontend`: Frontend-related changes

## 🤝 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/). Please read and follow it in all interactions.

## 📞 Getting Help

- 💬 [Discussions](https://github.com/LederWorks/siros/discussions) - Questions and community support
- 📧 [Email](mailto:support@lederworks.com) - Direct support
- 🐛 [Issues](https://github.com/LederWorks/siros/issues) - Bug reports and feature requests

## 🙏 Recognition

Contributors will be acknowledged in our release notes and documentation. We appreciate all contributions, big and small!

Thank you for contributing to Siros! 🌟
