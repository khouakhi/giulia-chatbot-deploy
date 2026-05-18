# Giulia — web chatbot (Docker)

**Giulia** is a web chatbot for the **SOILL** work on EU **Mission Soil** living labs and lighthouses. It answers from your **project documents** (PDFs, Word files, text) using AI, and points to **sources** where it found the information.

This repository runs Giulia **inside Docker** so you can host it on a server or a cloud provider. You supply a **MongoDB** database (we use **MongoDB Atlas** in the cloud) and a **Mistral** API key as settings — not in public files.

**Full project and source code:** [Giulia-Chatbot on GitHub](https://github.com/rendzina/Giulia-Chatbot) (formerly Giulia-Chatbot-v1). The Docker image clones that repo at build time. For ingestion, conversation logging, and PDF reports, see the upstream README.

**Credits:** Professor Stephen Hallett, Cranfield University, 2026.  
**Licence:** same as the main Giulia project (CC-BY-4.0 — see the link above).

### Deploying updates from upstream

1. Push any changes to this deploy repo if you changed `Dockerfile` or entrypoint.
2. On Render: **Manual Deploy → Clear build cache & deploy** so the image re-clones `Giulia-Chatbot` and reinstalls dependencies.
3. Ensure `MONGODB_URI` and `MISTRAL_API_KEY` are set. Logging is on by default (`LOG_CONVERSATIONS=true`); chats go to the `giulia_conversations` collection in the same database.
4. After a full re-ingest elsewhere, set `REBUILD_FAISS_ON_START=1` once (or redeploy with an empty FAISS volume) so the container rebuilds its local index from Atlas.

**Conversation reports** (`Reporter.py`) are run locally against the same `MONGODB_URI`, not inside this container.

---

Last updated: 08-05-2026.
