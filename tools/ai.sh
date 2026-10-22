#!/usr/bin/env bash

export PATH=$HOME/.opencode/bin:$PATH

# supports https://github.com/LaiZhou/OpenCode_UI/
opencode_create_facade() {
    local facade_path="$HOME/.opencode/bin/opencode"
    local script_dir
    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

    echo "📝 Creating opencode facade at $facade_path"
    mkdir -p "$HOME/.opencode/bin"

    cp "$script_dir/ai.d/opencode-facade.sh" "$facade_path"

    chmod +x "$facade_path"
    echo "✅ Facade erstellt und ausführbar gemacht"
    echo "💡 Füge $HOME/.opencode/bin zu \$PATH hinzu für globalen Zugriff"
}

# support tokscale
# see https://github.com/junhoyeo/tokscale#copilot-cli
if command -v copilot >/dev/null ; then
  export COPILOT_OTEL_ENABLED=true
  export COPILOT_OTEL_EXPORTER_TYPE=file
  mkdir -p "$HOME/.copilot/otel"
  export COPILOT_OTEL_FILE_EXPORTER_PATH="$HOME/.copilot/otel/copilot-otel-$(date +%Y%m%d-%H%M%S).jsonl"
fi
