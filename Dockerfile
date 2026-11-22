FROM debian:forky-slim

ENV DEBIAN_FRONTEND=noninteractive
# Install build tools, Python, and runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    fakeroot \
    libssl-dev \
    mtd-utils \
    squashfs-tools \
    && apt-get clean

# Switch working directory
WORKDIR /workspace

COPY --from=ghcr.io/astral-sh/uv:0.13 /uv /bin/
ENV UV_PROJECT_ENVIRONMENT="/root/.venv"
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PYTHON_PREFERENCE=only-managed
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev
ENV PATH="/root/.venv/bin:$PATH"

CMD ["/usr/bin/env", "bash"]
