# Giulia Chatbot — cloud deploy (Docker + Atlas)

This repository stays **separate** from [Giulia-Chatbot-v1](https://github.com/rendzina/Giulia-Chatbot-v1). It only holds **Docker** wiring so the upstream app repo stays clean.

The image **clones Giulia at build time**, installs dependencies, and runs **Chainlit** with your **MongoDB Atlas** URI and **Mistral** API key supplied as environment variables (platform secrets).

## Why FAISS is mentioned

Giulia answers using a **local FAISS file** plus **MongoDB**. After you ingest chunks into Atlas (from your laptop or with `RUN_INGEST_ON_START=1`), a new container has no `data/faiss/` yet. The bundled **entrypoint** rebuilds FAISS from MongoDB when `data/faiss/index.faiss` is missing (or when you set `REBUILD_FAISS_ON_START=1`). Ephemeral disks lose that folder on restart unless you attach a volume; the default entrypoint rebuilds again when the file is missing.

## MongoDB Atlas (one-time)

1. Create a **free M0** cluster (or larger).
2. **Database user** with read/write on your database (e.g. `giulia`).
3. **Network access**: for a quick demo, `0.0.0.0/0` is common; tighten to your PaaS egress IPs later.
4. **Connection string**: choose **Drivers → Python**, copy the **SRV** URI, replace `<password>`, and ensure the path ends with your database name, e.g. `...mongodb.net/giulia?retryWrites=true&w=majority`.
5. Set that value as **`MONGODB_URI`** in your host or platform secrets.

## Populate Atlas (choose one)

**A. Ingest from your machine (typical)**  
Use your existing Giulia clone: point `.env` **`MONGODB_URI`** at Atlas, run `python ProcessFiles.py`, then deploy this image. On first container start, FAISS rebuilds from Atlas automatically.

**B. Ingest inside the container**  
Add your PDFs/DOCX/TXT under `SourceDocuments/` (custom image or mounted volume), set **`RUN_INGEST_ON_START=1`**, and ensure **`MISTRAL_API_KEY`** is set. The container runs `ProcessFiles.py` before Chainlit. This is slower on boot and uses Mistral embedding quota.

## Local test with Docker Compose

```bash
cp .env.example .env
# Edit .env: MISTRAL_API_KEY, MONGODB_URI (Atlas)

docker compose up --build
```

Open `http://127.0.0.1:8000`.

## Build arguments (fork or pinned ref)

```bash
docker build \
  --build-arg GIULIA_REPO=https://github.com/your-org/Giulia-Chatbot-v1.git \
  --build-arg GIULIA_REF=main \
  -t giulia-atlas .
```

## Platform secrets (pattern)

Set the same variables as `.env.example`:

| Variable | Notes |
|----------|--------|
| `MISTRAL_API_KEY` | Required |
| `MONGODB_URI` | Atlas SRV URI including `/giulia` (or your DB name) |
| `MISTRAL_EMBED_MODEL` | Optional default `mistral-embed` |
| `MISTRAL_CHAT_MODEL` | Optional default `mistral-small-latest` |
| `RAG_TOP_K` | Optional |
| `PORT` | Many platforms set this automatically (Railway, Render, Fly) |

Optional:

| Variable | Effect |
|----------|--------|
| `RUN_INGEST_ON_START=1` | Run `ProcessFiles.py` on every container start |
| `REBUILD_FAISS_ON_START=1` | Always rebuild FAISS from Mongo before Chainlit |

## Railway / Render / Fly (outline)

- **Build command**: none (Dockerfile only).
- **Start command**: use image default entrypoint (do not override unless you know what you are doing).
- **Health**: HTTP check on `/` or Chainlit’s URL (platform-specific).
- **Atlas**: allow outbound from the region your PaaS uses, or temporarily `0.0.0.0/0` for a demo.

Last updated: 30-04-2026 (UK style).
