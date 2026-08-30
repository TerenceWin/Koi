FROM python:3.11-slim

# Pinned rather than :latest so image builds stay reproducible over time.
COPY --from=ghcr.io/astral-sh/uv:0.11 /uv /usr/local/bin/uv

WORKDIR /app

# Manifests first, so this layer stays cached until dependencies actually
# change. Copying source before this would reinstall everything on every edit.
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY . .

# Cloud Run injects PORT; the default keeps plain `docker run` working locally.
ENV PORT=8080
EXPOSE 8080

# Invoke the venv binary directly rather than `uv run` — uv run re-syncs the
# environment on every container start, adding a PyPI round trip to boot.
# `exec` replaces the shell so uvicorn receives SIGTERM and shuts down cleanly.
CMD ["sh", "-c", "exec .venv/bin/uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
