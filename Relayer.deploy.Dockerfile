# Stage 1: Compile contracts
FROM node:20-bookworm-slim AS contracts

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates curl && rm -rf /var/lib/apt/lists/*
RUN curl -L https://foundry.paradigm.xyz | bash && /root/.foundry/bin/foundryup
ENV PATH="/root/.foundry/bin:${PATH}"

WORKDIR /build

COPY package.json yarn.lock ./
COPY packages/contracts/package.json packages/contracts/
RUN yarn install --non-interactive

COPY packages/contracts packages/contracts
WORKDIR /build/packages/contracts
RUN forge build --skip '*ZKSync*'

# Stage 2: Build relayer
FROM rust:1.94-bookworm

COPY --from=contracts /build/packages/contracts/artifacts/EmailAuth.sol/EmailAuth.json /relayer/packages/contracts/artifacts/EmailAuth.sol/EmailAuth.json
COPY --from=contracts /build/packages/contracts/artifacts/UserOverrideableDKIMRegistry.sol/UserOverrideableDKIMRegistry.json /relayer/packages/contracts/artifacts/UserOverrideableDKIMRegistry.sol/UserOverrideableDKIMRegistry.json
COPY packages/relayer /relayer/packages/relayer

WORKDIR /relayer/packages/relayer

RUN cargo build

RUN chmod +x entrypoint.sh

EXPOSE 4500

ENTRYPOINT ["./entrypoint.sh"]
CMD ["cargo", "run"]

