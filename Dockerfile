# ================================
# Build image
# ================================
FROM swift:5.6.1-amazonlinux2 as builder

WORKDIR /root
COPY . .
RUN swift build -c release

# ================================
# Run image
# ================================
FROM swift:5.6.1-amazonlinux2-slim

WORKDIR /root
COPY --from=builder /root .
CMD [".build/release/TitechOCWScraping"]