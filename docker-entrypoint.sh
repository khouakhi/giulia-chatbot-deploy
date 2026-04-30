#!/bin/sh
set -e
cd /app

# Optional: ingest from SourceDocuments/ (needs corpus in image or volume).
if [ "${RUN_INGEST_ON_START:-0}" = "1" ]; then
  echo "Running ProcessFiles.py (RUN_INGEST_ON_START=1)..."
  python ProcessFiles.py
fi

# Giulia answers from FAISS on disk + MongoDB. After you ingest against Atlas
# elsewhere, a fresh container has no index; rebuild from Mongo when missing.
if [ ! -f data/faiss/index.faiss ] || [ "${REBUILD_FAISS_ON_START:-0}" = "1" ]; then
  echo "Rebuilding FAISS from MongoDB..."
  python -c "import giulia.config as _c; from giulia import store_faiss; n = store_faiss.rebuild_faiss_from_mongo(); print('FAISS vectors:', n)"
fi

PORT="${PORT:-8000}"
exec chainlit run app.py --headless --host 0.0.0.0 --port "${PORT}"
