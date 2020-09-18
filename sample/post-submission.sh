#!/usr/bin/env sh
curl \
  --cacert server.crt \
  --cert client.crt \
  --key client.key \
  --pass passwordForClientKey \
  -H "API-Key: d082af99-0576-4dae-8ef0-35ad32e937d4" \
  -F "message=@sample-message.json;type=application/json" \
  -F "files=@sample-document.pdf" \
  -F "files=@sample-attachment.png" \
  https://myendpoint.mydomain:8443/api/submission-dispatch/submissions
