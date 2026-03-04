# MoonPay DevOps Challenge

A Next.js application displaying cryptocurrency prices, built with Prisma 7 and PostgreSQL.
 this a test
## Tech Stack

- **Framework**: Next.js 16 (App Router, Turbopack)
- **Language**: TypeScript 5.9 (ESM)
- **Database**: PostgreSQL 17 with Prisma 7 + pg adapter
- **Styling**: Tailwind CSS 4 (CSS-first configuration)
- **Runtime**: Node.js 22 LTS
- **Package Manager**: pnpm

## Quick Start

### Prerequisites

- Node.js 22+ (`nvm use` or `mise install`)
- pnpm (`corepack enable pnpm`)
- Docker (for PostgreSQL)

### Setup

```bash
# Set up environment
cp .env.example .env

# Install dependencies (runs prisma generate automatically)
pnpm install

# Start PostgreSQL
docker compose up -d postgres

# Run migrations
pnpm db:migrate

# Start development server
pnpm dev
```

The app will be available at [http://localhost:3000](http://localhost:3000).

## Available Scripts

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start development server with Turbopack |
| `pnpm build` | Build for production |
| `pnpm start` | Start production server |
| `pnpm db:migrate` | Run database migrations |
| `pnpm db:push` | Push schema changes (no migration) |
| `pnpm db:studio` | Open Prisma Studio GUI |

## Project Structure

```
├── app/                  # Next.js App Router
│   ├── layout.tsx        # Root layout with fonts
│   ├── page.tsx          # Home page with currency table
│   └── globals.css       # Tailwind @theme configuration
├── components/           # React components
│   ├── table.tsx         # Currency table (Server Component)
│   └── table-placeholder.tsx  # Loading skeleton
├── lib/
│   └── prisma.ts         # Prisma client with pg adapter
├── prisma/
│   ├── schema.prisma     # Database schema
│   ├── generated/        # Generated Prisma client (gitignored)
│   └── migrations/       # SQL migrations
├── prisma.config.ts      # Prisma configuration
├── docker-compose.yaml   # PostgreSQL + Next.js services
└── Dockerfile            # Production container (you need to create this)
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `POSTGRES_PRISMA_URL` | PostgreSQL connection string |

Example: `postgres://postgres:postgres@localhost:5432/currencies?schema=public`

## Database

### Schema

```prisma
model currencies {
  id        Int      @id @default(autoincrement())
  name      String
  code      String   @unique
  icon      String
  price     Decimal  @db.Decimal(15, 5)
  createdAt DateTime @default(now())
}
```

### Prisma 7 with pg Adapter

This project uses Prisma 7's driver adapter architecture with `node-postgres` for connection pooling. The client is generated to `prisma/generated/` and configured in `prisma.config.ts`.

## Docker

```bash
# Start PostgreSQL only
docker compose up -d postgres

# Start full stack (requires Dockerfile)
docker compose up -d
```

## Kubernetes Deployment

### Prerequisites

- A running Kubernetes cluster
- Helm 3+
- `kubectl` configured

### Create the PostgreSQL secret

```bash
kubectl create secret generic postgres-postgres \
  --from-literal=POSTGRES_USER="postgres" \
  --from-literal=POSTGRES_PASSWORD="postgres" \
  --from-literal=POSTGRES_DB="currencies"
```

### Deploy PostgreSQL

```bash
helm install postgres ./charts/postgres
```

### Create the application secret

```bash
kubectl create secret generic moonpay-app \
  --from-literal=POSTGRES_PRISMA_URL="postgresql://postgres:postgres@postgres-postgres:5432/currencies"
```

### Deploy the application

```bash
helm install moonpay ./charts/moonpay-app
```

Database migrations run automatically as a pre-install/pre-upgrade Helm hook.
