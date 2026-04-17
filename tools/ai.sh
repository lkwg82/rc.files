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

# OpenCode Facade Script

# see https://nono.sh/
alias nono_opencode_ide='nono run --profile opencode --allow-cwd --read $HOME/.copilot --read $HOME/ghorg --allow $HOME/.local/state/opencode -- /opt/homebrew/bin/opencode --hostname 127.0.0.1 --port 4096 --continue'
shopt -s expand_aliases

if [[ -n "${NO__NONO:-}" ]]; then
    command opencode "$@"
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
