#!/usr/bin/env bash

export PATH=$HOME/.opencode/bin:$PATH

# supports https://github.com/LaiZhou/OpenCode_UI/
opencode_create_facade() {
    local facade_path="$HOME/.opencode/bin/opencode"

    echo "📝 Creating opencode facade at $facade_path"
    mkdir -p "$HOME/.opencode/bin"

    cat > "$facade_path" << 'EOF'
#!/usr/bin/env bash

set -eu

if [[ -n ${DEBUG:-} ]]; then
  set -x
fi

unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  platform='darwin'
fi

# OpenCode Facade Script

# see https://nono.sh/
  if [[ ${platform} == "darwin" ]]; then
    original_path="/opt/homebrew/bin/opencode"
  else
    original_path="/home/linuxbrew/.linuxbrew/bin/opencode"
    nono_extra_args='--read /home/linuxbrew/.linuxbrew/ --read $HOME/.sdkman --allow $HOME/.m2'
  fi
  alias nono_opencode_ide='nono run --profile opencode --allow-cwd --read $HOME/.copilot --read $HOME/ghorg --allow $HOME/.local/state/opencode '${nono_extra_args:-}' -- '${original_path}' --hostname 127.0.0.1 --port 4096 --continue'

shopt -s expand_aliases

if [[ -n "${NO__NONO:-}" ]]; then
    ${original_path} "$@"
else
    echo "🔧 Setze NO__NONO=1 um originales opencode zu nutzen"
    echo "📍 Quelle: ~/.bashrc.d/tools/ai.sh"
    echo "🔒 Nutze nono für sicheren opencode-Aufruf:"
    alias nono_opencode_ide
    echo " -------------- delay ------"
    sleep 2
    nono_opencode_ide

fi
EOF
    
    chmod +x "$facade_path"
    echo "✅ Facade erstellt und ausführbar gemacht"
    echo "💡 Füge $HOME/.opencode/bin zu \$PATH hinzu für globalen Zugriff"
}



# see https://github.com/nolabs-ai/nono
# because brew install nono still returns 0.73 (before namespace migration from always-further to nolabs-ai)
nono_manual_install() {
    local version='v0.74.0'
    local unamestr
    unamestr=$(uname)

    local target
    if [[ $unamestr == 'Darwin' ]]; then
        target='aarch64-apple-darwin'
    elif [[ $unamestr == 'Linux' ]]; then
        target="$(uname -m)-unknown-linux-gnu"
    else
        echo "❌ Nicht unterstützte Plattform: $unamestr"
        return 1
    fi

    local url="https://github.com/nolabs-ai/nono/releases/download/${version}/nono-${version}-${target}.tar.gz"
    mkdir -p "$HOME/bin"

    echo "⬇️  Lade nono ${version} für ${target} herunter..."
    curl -fsSL "$url" | tar -xz -C "$HOME/bin"
    chmod +x "$HOME/bin/nono"
    echo "✅ nono installiert unter $HOME/bin/nono"
}

# support tokscale
# see https://github.com/junhoyeo/tokscale#copilot-cli
if command -v copilot >/dev/null ; then
  export COPILOT_OTEL_ENABLED=true
  export COPILOT_OTEL_EXPORTER_TYPE=file
  mkdir -p "$HOME/.copilot/otel"
  export COPILOT_OTEL_FILE_EXPORTER_PATH="$HOME/.copilot/otel/copilot-otel-$(date +%Y%m%d-%H%M%S).jsonl"
fi