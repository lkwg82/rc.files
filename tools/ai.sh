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

if [[ -z ${DEBUG:-} ]]; then
  set -x
fi

unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  # shellcheck disable=SC2034
  platform='darwin'
fi

# OpenCode Facade Script

# see https://nono.sh/
  if [[ ${platform} == "darwin" ]]; then
    original_path="/opt/homebrew/bin/opencode"
  else
    original_path="/home/linuxbrew/.linuxbrew/bin/opencode"
  fi
  alias nono_opencode_ide='nono run --profile opencode --allow-cwd --read $HOME/.copilot --read $HOME/ghorg --allow $HOME/.local/state/opencode -- '${original_path}' --hostname 127.0.0.1 --port 4096 --continue'

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
