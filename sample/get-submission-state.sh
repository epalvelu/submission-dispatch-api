#!/usr/bin/env sh
curl \
  --cacert server.crt \
  --cert client.crt \
  --key client.key \
  --pass passwordForClientKey \
  -H "API-Key: d082af99-0576-4dae-8ef0-35ad32e937d4" \
  https://myendpoint.mydomain:8443/api/submission-dispatch/submissions/a37fea75-a2a8-4898-ab70-bf0e8b6f5c3b
