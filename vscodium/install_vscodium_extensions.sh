#!/bin/bash

cat extensions.txt | xargs -L 1 codium --install-extension
