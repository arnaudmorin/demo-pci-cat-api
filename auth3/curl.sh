curl -s -X POST https://auth.cloud.ovh.net/v3/auth/tokens \
 -H "Content-Type: application/json" \
"{
  "auth": {
    "identity": {
      "methods": [
        "password"
      ],
      "password": {
        "user": {
          "domain": {
            "name": "Default"
          },
          "name": "nUv3vY3TjWDV",
          "password": "pass"
        }
      }
    },
    "scope": {
      "project": {
        "id": "0d899a6f76d74760a06919233ed0ec51"
      }
    }
  }"
