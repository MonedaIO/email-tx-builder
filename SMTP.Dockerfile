# Use the official Rust image as a base image
FROM rust:latest

# Prefer IPv4 over IPv6 in glibc's getaddrinfo so SMTP DNS lookups
# don't hand back an IPv6 address on IPv4-only container networks.
RUN echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf

# Set the working directory inside the container
WORKDIR /app

# Clone the GitHub repository
RUN git clone https://github.com/zkfriendly/relayer-smtp.git

# Change to the directory of the cloned repository
WORKDIR /app/relayer-smtp

# Build the Rust package
RUN cargo build

# Expose port
EXPOSE 3000

# Specify the command to run when the container starts
CMD ["cargo", "run", "--bin", "relayer-smtp"]