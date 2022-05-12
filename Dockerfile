# ================================
# Build image
# ================================
FROM swift:5.6.1-focal as build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release --static-swift-stdlib

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/TitechOCWScraping" ./


# ================================
# Run image
# ================================
FROM ubuntu:focal

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && apt-get -q install -y ca-certificates tzdata curl && \
    rm -r /var/lib/apt/lists/*

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build /staging /app

CMD ["./TitechOCWScraping"]