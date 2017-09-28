#!/bin/bash

[ $(python --version | awk '{print $2}' | awk -F'.' '{print $1}') -eq 3 ] && \
    python -m http.server 8000 \
|| \
    python -m SimpleHTTPServer 8000
