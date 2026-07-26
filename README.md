# Delego

<div align="center">

**AI-Powered Delegated Commerce on Stellar**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stellar](https://img.shields.io/badge/Stellar-Soroban-blue)](https://soroban.stellar.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.70-orange)](https://www.rust-lang.org/)

</div>

## 🌟 Overview

Delego is an AI commerce platform where users delegate shopping and payment tasks to AI agents while maintaining approval and spending controls. Built on Stellar and Soroban, Delego provides secure wallet management, escrow services, settlement mechanisms, and permission systems for trusted agent-mediated commerce.

### 🎯 Key Features

- **AI Agent Delegation**: Delegate shopping and payment tasks to specialized AI agents
- **Spending Controls**: Set approval thresholds and spending limits for agent actions
- **Secure Escrow**: Stellar-powered escrow contracts protect buyers in agent-mediated transactions
- **Permission Management**: Granular Soroban-based permissions for delegated spending authority
- **Transparent Auditing**: Complete audit trail of all agent actions and transactions
- **Multi-Agent Orchestration**: Coordinated buyer, payment, and delivery agents
- **Wallet Integration**: Seamless Stellar wallet management and Soroban contract interaction

### 🏗️ Architecture

Delego follows a microservices architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                         User Layer                          │
│                  Web App (apps/frontend)                    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          v
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway                            │
│           (apps/backend/gateway - Port 3000)                │
│              Auth, Rate Limiting, Routing                    │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        v                 v                 v
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Orchestrator │  │   Wallet     │  │  Payments    │
│  (3010)      │  │   Service    │  │   Service    │
│              │  │   (3012)     │  │   (3014)     │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       v                 v                 v
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Agents     │  │   Stellar    │  │   Soroban   │
│   (3011)     │  │   Network    │  │   Contracts │
│              │  │              │  │              │
└──────────────┘  └──────────────┘  └──────┬───────┘
                                           │
                            ┌──────────────┼──────────────┐
                            │              │              │
                            v              v              v
                     ┌──────────┐  ┌──────────┐  ┌──────────┐
                     │  Escrow  │  │Permissions│  │Reputation│
                     │ Contract │  │ Contract │  │ Contract │
                     └──────────┘  └──────────┘  └──────────┘
```

**Supporting Services:**
- **Notifications Service** (3015): Customer-facing updates and alerts
- **PostgreSQL**: User data, delegations, orders, audit logs
- **Redis**: Session management, rate limiting, workflow state cache

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Development Commands](#development-commands)
- [Architecture](#architecture)
- [Smart Contracts](#smart-contracts)
- [Testing](#testing)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)

## 🚀 Quick Start

Get Delego running locally in under 5 minutes:

```bash
# Clone the repository
git clone https://github.com/your-org/delego.git
cd delego

# Install dependencies
pnpm install

# Configure environment
cp .env.example .env
# Edit .env with your local configuration

# Start infrastructure (PostgreSQL, Redis)
pnpm docker:up

# Run database migrations
pnpm db:migrate

# Seed development data (optional)
pnpm db:seed

# Start all services
pnpm dev
```

Access the applications:
- **Web App**: http://localhost:3001
- **API Gateway**: http://localhost:3000
- **API Health**: http://localhost:3000/health

## 🔧 Prerequisites

Ensure you have the following installed:

- **Node.js** >= 20.0.0 ([Download](https://nodejs.org/))
- **pnpm** >= 9.0.0 ([Installation](https://pnpm.io/installation))
- **Docker** >= 24.0.0 ([Download](https://www.docker.com/))
- **Docker Compose** >= 2.20.0
- **Rust** >= 1.70.0 ([Installation](https://www.rust-lang.org/tools/install))
- **Soroban CLI** (optional, for contract development) ([Setup Guide](https://soroban.stellar.org/docs/getting-started/setup))

### Rust Target for Soroban

```bash
rustup target add wasm32-unknown-unknown
```

## 💻 Development Setup

### 1. Environment Configuration

Copy the example environment file and configure it:

```bash
cp .env.example .env
```

Key environment variables:
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `STELLAR_NETWORK`: `testnet` or `mainnet`
- `SOROBAN_RPC_URL`: Soroban RPC endpoint
- `JWT_SECRET`: Secret for JWT token signing

### 2. Infrastructure Services

Start PostgreSQL and Redis using Docker Compose:

```bash
pnpm docker:up
```

### 3. Database Setup

Apply migrations and seed development data:

```bash
pnpm db:migrate
pnpm db:seed
```

### 4. Build Contracts

Build Soroban smart contracts:

```bash
cd contracts
cargo build --target wasm32-unknown-unknown --release
```

### 5. Development Mode

Start all services in development mode:

```bash
# Start everything
pnpm dev

# Or start individual services
pnpm dev:web          # Customer web app -> http://localhost:3001
pnpm dev:gateway      # API gateway      -> http://localhost:3000
pnpm dev:orchestrator # Orchestrator     -> http://localhost:3010
pnpm dev:agents       # Agents service   -> http://localhost:3011
pnpm dev:wallet       # Wallet service   -> http://localhost:3012
pnpm dev:payments     # Payments service -> http://localhost:3014
pnpm dev:notifications# Notifications    -> http://localhost:3015
```

## 📁 Project Structure

Delego is organized as a monorepo using pnpm workspaces:

```
delego/
├── apps/                    # Applications
│   ├── frontend/            # Customer web application (Next.js)
│   └── backend/             # Backend microservices
│       ├── gateway/         # API gateway with auth & routing
│       ├── orchestrator/    # Purchase workflow coordination
│       ├── wallet/          # Stellar wallet & Soroban integration
│       ├── payments/        # Payment & escrow coordination
│       └── notifications/   # Email & push notifications
├── agents/                  # AI agent runtime and packages
├── contracts/              # Soroban smart contracts
│   ├── escrow/             # Escrow contract for purchase funds
│   └── permissions/        # Delegated spending permissions
├── packages/               # Shared libraries
│   ├── ui/                 # React component library
│   ├── sdk/                # API client SDK
│   ├── types/              # TypeScript type definitions
│   └── utils/              # Shared utilities (logger, HTTP, etc.)
├── database/               # Database schema & migrations
│   ├── schema/             # Initial schema
│   ├── migrations/         # Versioned migrations
│   └── seed/               # Development seed data
├── infrastructure/         # Infrastructure as code
│   ├── docker/             # Docker configurations
│   ├── terraform/          # Terraform configurations
│   ├── monitoring/         # Monitoring & alerting
│   └── deployment/        # Deployment scripts
├── tests/                  # Test suites
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   ├── e2e/                # End-to-end tests
│   └── contracts/          # Smart contract tests
├── docs/                   # Documentation
│   ├── architecture/       # Technical architecture docs
│   ├── api-reference.md    # API documentation
│   ├── contributor-guide.md# Contributor guide
│   └── vision.md           # Product vision
├── scripts/                # Utility scripts
│   ├── setup/              # Setup scripts
│   ├── generate/           # Code generation
│   └── deploy/             # Deployment utilities
├── .github/                # GitHub configurations
│   ├── workflows/          # CI/CD workflows
│   └── ISSUE_TEMPLATE/     # Issue templates
├── .env.example            # Environment variables template
├── docker-compose.yml      # Local development infrastructure
├── pnpm-workspace.yaml     # pnpm workspace configuration
├── package.json            # Root package.json
└── tsconfig.base.json      # Base TypeScript configuration
```

## 🛠️ Development Commands

### Workspace Commands

| Command | Description |
|---------|-------------|
| `pnpm install` | Install all workspace dependencies |
| `pnpm build` | Build all packages, apps, services, and contract wrappers |
| `pnpm dev` | Start web app and all services in parallel |
| `pnpm clean` | Clean build artifacts and node_modules |

### Individual Services

| Command | Description | Port |
|---------|-------------|------|
| `pnpm dev:web` | Start customer web app | 3001 |
| `pnpm dev:gateway` | Start API gateway | 3000 |
| `pnpm dev:orchestrator` | Start orchestrator service | 3010 |
| `pnpm dev:agents` | Start agents service | 3011 |
| `pnpm dev:wallet` | Start wallet service | 3012 |
| `pnpm dev:payments` | Start payments service | 3014 |
| `pnpm dev:notifications` | Start notifications service | 3015 |

### Code Quality

| Command | Description |
|---------|-------------|
| `pnpm typecheck` | Type-check all TypeScript projects |
| `pnpm lint` | Run ESLint on all packages |
| `pnpm lint:fix` | Auto-fix linting issues |
| `pnpm format` | Format code with Prettier |

### Testing

| Command | Description |
|---------|-------------|
| `pnpm test` | Run all test suites |
| `pnpm test:unit` | Run unit tests |
| `pnpm test:integration` | Run integration tests |
| `pnpm test:contracts` | Run Soroban contract tests |
| `pnpm test:e2e` | Run end-to-end tests |
| `pnpm test:watch` | Run tests in watch mode |
| `pnpm test:coverage` | Generate test coverage report |

### Database

| Command | Description |
|---------|-------------|
| `pnpm docker:up` | Start PostgreSQL and Redis containers |
| `pnpm docker:down` | Stop and remove infrastructure containers |
| `pnpm db:migrate` | Apply pending database migrations |
| `pnpm db:migrate:rollback` | Rollback last migration |
| `pnpm db:seed` | Seed development data |
| `pnpm db:reset` | Reset database (migrate + seed) |

### Smart Contracts

| Command | Description |
|---------|-------------|
| `cd contracts && cargo test` | Run contract tests |
| `cd contracts/escrow && cargo build --target wasm32-unknown-unknown --release` | Build escrow contract |
| `cd contracts/permissions && cargo build --target wasm32-unknown-unknown --release` | Build permissions contract |

## 🏛️ Architecture

Delego implements a layered microservices architecture:

### Service Responsibilities

| Service | Responsibility | Tech Stack |
|---------|----------------|------------|
| **Gateway** | HTTP API, authentication, rate limiting, request routing | Node.js, Express |
| **Orchestrator** | Customer purchase workflow coordination | Node.js, TypeScript |
| **Agents** | AI agent runtime and execution | Node.js, LLM APIs |
| **Wallet** | Stellar keys, Soroban permissions, transaction signing | Node.js, Stellar SDK |
| **Payments** | Escrow coordination, settlement, payment events | Node.js, Soroban |
| **Notifications** | Customer notifications and templates | Node.js, SendGrid |

### Data Stores

- **PostgreSQL**: Users, delegations, orders, audit logs
- **Redis**: Sessions, rate limits, workflow state cache
- **Soroban**: Escrow funds, delegated permissions, reputation scores

### Cross-Cutting Concerns

- **Authentication**: JWT via gateway; wallet addresses as identity
- **Authorization**: Role-based access control with wallet-based permissions
- **Spending Controls**: Permissions contract and wallet service policy checks
- **Observability**: Structured logging with correlation IDs
- **Security**: End-to-end encryption for sensitive data

For detailed architecture documentation, see [ARCHITECTURE.md](./ARCHITECTURE.md) and [docs/architecture/](./docs/architecture/).

## 🔐 Smart Contracts

Delego uses Soroban smart contracts for trust-critical operations:

### Escrow Contract
- Holds purchase funds in secure escrow
- Releases funds upon delivery confirmation
- Supports refunds for disputed transactions
- Time-locked release mechanisms

### Permissions Contract
- Manages delegated spending authority
- Enforces spending limits and approval thresholds
- Supports time-based permission grants
- Revocable permissions

### Reputation Contract (Planned)
- Tracks cumulative reputation scores
- Merchant and agent reputation
- Influences escrow terms and limits

For contract development details, see [contracts/README.md](./contracts/README.md).

## 🧪 Testing

Delego employs a comprehensive testing strategy:

### Test Suites

- **Unit Tests**: Test individual functions and components in isolation
- **Integration Tests**: Test service interactions and database operations
- **Contract Tests**: Test Soroban contract logic with soroban-sdk
- **E2E Tests**: Test complete user flows from web app to blockchain

### Running Tests

```bash
# Run all tests
pnpm test

# Run specific test suites
pnpm test:unit
pnpm test:integration
pnpm test:contracts
pnpm test:e2e

# Run tests with coverage
pnpm test:coverage
```

For testing guidelines, see [tests/README.md](./tests/README.md).

## 🤝 Contributing

We welcome contributions from the community! Please follow these guidelines:

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes with clear, focused commits
4. Ensure all tests pass: `pnpm test`
5. Submit a pull request with a detailed description

### Code Standards

- **TypeScript**: Strict mode, no `any` without justification
- **Rust**: Follow Soroban best practices, include contract tests
- **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/)
- **Documentation**: Update READMEs and add comments for complex logic

### Pull Request Process

1. Ensure your code passes all linting and type checks
2. Add tests for new functionality
3. Update documentation as needed
4. Use the PR template and describe your changes
5. Request review from maintainers

For detailed contribution guidelines, see [CONTRIBUTING.md](./CONTRIBUTING.md) and [docs/contributor-guide.md](./docs/contributor-guide.md).

## 🗺️ Roadmap

### Phase 0 - Foundation ✅
- [x] Monorepo scaffold
- [x] CI/CD pipeline skeleton
- [x] Docker Compose for Postgres and Redis
- [ ] Contributor onboarding docs
- [ ] Soroban local dev environment

### Phase 1 - Customer Web MVP (In Progress)
- [ ] API gateway with auth middleware
- [ ] Shared types and SDK package
- [ ] Wallet service with Stellar account and Soroban permissions support
- [ ] Escrow contract deploy and test flow
- [ ] Orchestrator purchase workflow skeleton
- [ ] Customer web app for wallet connection and delegations

### Phase 2 - Agent Purchase Flow
- [ ] Buyer agent runtime
- [ ] Spending limit enforcement through wallet and permissions services
- [ ] Approval flow before escrow funding or settlement
- [ ] Customer notifications

### Phase 3 - Production Readiness
- [ ] Terraform infrastructure
- [ ] Monitoring and alerting
- [ ] Mainnet deployment
- [ ] Security audit

### Future Expansions
- Merchant application for sellers
- Mobile applications (iOS/Android)
- Delivery agent integration
- Multi-chain support
- Advanced AI agent capabilities

For detailed roadmap, see [ROADMAP.md](./ROADMAP.md).

## 📚 Documentation

- [Architecture Overview](./ARCHITECTURE.md)
- [Contributing Guide](./CONTRIBUTING.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [API Reference](./docs/api-reference.md)
- [Technical Architecture](./docs/architecture/)
- [Contributor Guide](./docs/contributor-guide.md)

## 🐛 Reporting Issues

Found a bug or have a feature request? Please:

1. Check existing [GitHub Issues](https://github.com/your-org/delego/issues)
2. Use the appropriate issue template
3. Provide reproduction steps, expected vs actual behavior
4. Include environment details (OS, Node version, etc.)

## 🔒 Security

Security is paramount for Delego. If you discover a security vulnerability:

- **Do not** open a public issue
- Email us at: security@delego.dev
- Include details and reproduction steps
- We will respond promptly and coordinate disclosure

## 📄 License

Delego is open-source software licensed under the [MIT License](./LICENSE).

## 🙏 Acknowledgments

- Built with [Stellar](https://www.stellar.org/) and [Soroban](https://soroban.stellar.org/)
- Inspired by the vision of trustworthy AI-agent commerce
- Community contributors and supporters

---

<div align="center">

**[⬆ Back to Top](#delego)**

Made with ❤️ by the Delego community

</div>
