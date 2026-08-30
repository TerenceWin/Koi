#!/bin/sh
# Runs after the base image's 20-envsubst-on-templates.sh, before nginx starts.
# Writes the runtime API URL into a file the app reads as window.__ENV__.
set -e

envsubst '${VITE_API_URL}' \
  < /etc/nginx/config.js.template \
  > /usr/share/nginx/html/config.js
