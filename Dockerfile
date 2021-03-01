FROM arm64v8/ubuntu AS build

RUN apt-get update
RUN apt-get install -y curl build-essential clang libclang-dev libc6-dev g++ llvm-dev
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY . /app
RUN cargo clean && cargo build --release --target aarch64-unknown-linux-gnu
RUN strip ./target/aarch64-unknown-linux-gnu/release/sonic

FROM arm64v8/ubuntu

WORKDIR /usr/src/sonic

COPY --from=build /app/target/aarch64-unknown-linux-gnu/release/sonic /usr/local/bin/sonic

CMD [ "sonic", "-c", "/etc/sonic.cfg" ]

EXPOSE 1491
