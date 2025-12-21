# craft.sh

Command-line tool for quick capture to Craft Documents. Never leave your terminal to capture thoughts, code snippets, or command output.

## Project Description

`craft.sh` is a lightweight bash script that streams text directly to your Craft daily notes. Pipe command output, capture error logs, or save code snippets—all without breaking your flow.

## Requirements

- **curl** - API requests
- **jq** - JSON processing
- **Craft API key and URL** - From Craft Imagine section

**Install dependencies:**
```bash
# macOS
brew install curl jq

# Ubuntu/Debian
sudo apt-get install curl jq
```

## Installation Instructions

```bash
# Clone and make executable
git clone https://github.com/gdamberg/craft.sh.git
cd craft.sh
chmod +x craft.sh

# Optional: Install system-wide
sudo cp craft.sh /usr/local/bin/

# Test
./craft.sh -h
```

**Configure API credentials:**

Get your Craft API Key and URL from within Craft Imagine section.

![Screenshot of Craft with the Imagine section open](craft-api.png)

```bash
# Option 1: Config file 
mkdir -p ~/.config/craft.sh
cat > ~/.config/craft.sh/config <<'EOF'
CRAFT_API_KEY="your-api-key-here"
CRAFT_API_URL="your-api-url-here"
EOF
chmod 600 ~/.config/craft.sh/config

# Option 2: Environment variables
export CRAFT_API_KEY="your-api-key-here"
export CRAFT_API_URL="https://api.craft.do/v1"
```

_Note!_ Environment variables take precedence over config file.

## Usage Instructions

**Note!** No input validation or cleaning is done so be aware of potential security risks. Don't pipe random commands to the script.

**Basic usage:**
```bash
craft.sh "Quick note"
```

**From pipes:**
```bash
echo "my computer username is ${USER}" | craft.sh
git log --oneline -5 | craft.sh --code
cat notes.txt | craft.sh
git diff | craft.sh --code
```

**From files:**
```bash
craft.sh < file.txt
cat file.md | craft.sh
```

**Multi-line (heredoc):**
```bash
craft.sh <<EOF
## Meeting Notes
- Point 1
- Point 2
EOF
```

**Clipboard (macOS)**
```bash
pbpaste | craft.sh
```

**Clipboard (Linux)**
```bash
xclip -o | craft.sh
```

## License

See [LICENSE](LICENSE)

## Links

- Repository: https://github.com/gdamberg/craft.sh
- Craft: https://www.craft.do
