#!/usr/bin/env bash


set -eu


nono profile schema --output nono-profile.schema.json
nono profile validate opencode-local.jsonc