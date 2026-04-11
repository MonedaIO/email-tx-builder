# Generic Relayer

## Prerequisites

- docker compose
- sqlx-cli

> **Note:** All commands in this guide should be executed from the repository root unless otherwise specified.

## Setup

### 1. Build contracts

```bash
yarn workspace @zk-email/email-tx-builder-contracts build
```

### 2. Configure relayer

Copy the config file:

```bash
cp packages/relayer/config.example.json packages/relayer/config.json
```

Edit `packages/relayer/config.json` and fill in:
- `chains.<network>.privateKey` - Private key for the used chains
- `prover.url` and `prover.apiKey` - Set up the prover (see the [prover setup guide](https://github.com/zkemail/email-gpu-prover)) and fill the `url` and the `apiKey` fields
- `icp.wallet_canisterId` - Set up the ICP (see the [ICP setup guide](https://proofofemail.notion.site/How-to-setup-ICP-account-for-relayer-cf80ad6187e94219b25152fb875309db)) and fill the `wallet_canisterId` field

> Note: Place the `.ic.pem` file in `packages/relayer/`

### 3. Configure environment

Copy and edit the `.env` file:

```bash
cp .env.example .env
```

Fill in the SMTP and IMAP credentials in `.env`.

### 4. Build and start services

```bash
docker compose up --build -d
```

This will spin up the docker containers for the imap, smtp and db services.

### 5. Apply the migrations

```bash
DATABASE_URL=postgres://relayer:relayer_password@localhost:5442/relayer sqlx migrate run --source ./packages/relayer/migrations
```
