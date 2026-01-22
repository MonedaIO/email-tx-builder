# Generic Relayer

## Prerequisites

- rust and cargo
- docker compose
- sqlx-cli


## Setup

### 1. Build contracts

```bash
yarn workspace @zk-email/email-tx-builder-contracts build
```

### 2. Configure relayer

In the relayer package directory (`./packages/relayer`) copy the config file:

```bash
cp config.example.json config.json
```

Edit `config.json` and fill in:
- `chains.<network>.privateKey` - Private key for the used chains
- `prover.*` - Deploy the prover (see the [prover setup guide](../prover/)) and fill all `prover` fields
- `icp.*` - Set up the ICP (see the [ICP setup guide](https://proofofemail.notion.site/How-to-setup-ICP-account-for-relayer-cf80ad6187e94219b25152fb875309db)) and fill all `icp` fields

> Note: do not forget to place the `.ic.pem` file in the relayer root

### 3. Configure environment

In the repository root, copy and edit the `.env` file:

```bash
cp .env.example .env
```

Fill in the SMTP and IMAP credentials in `.env`.

### 4. Build relayer

```bash
cargo build --release
```

### 5. Build and start services

From the repository root:

```bash
docker compose up --build -d
```

This will spin up the docker containers for the imap, smtp and db services.

### 6. Apply the migrations

```bash
DATABASE_URL=postgres://relayer:relayer_password@localhost:5432/relayer sqlx migrate run
```
