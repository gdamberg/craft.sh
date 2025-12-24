#!/usr/bin/env bash
set -euo pipefail

readonly VERSION="0.0.1"
readonly SOURCE_REPO="https://github.com/gdamberg/craft.sh/"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/craft.sh"
CONFIG_FILE="${CONFIG_DIR}/config"

# Log level: debug, info, error
LOG_LEVEL="${LOG_LEVEL:-info}"

# Environment variables (can be set via env or config file)
CRAFT_API_KEY="${CRAFT_API_KEY:-}"
CRAFT_API_URL="${CRAFT_API_URL:-}"

### functions ###
dependency_check() {
  local missing_deps=0
  for cmd in "curl" "jq"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      echo "ERROR: Required command '${cmd}' not found." >&2
      missing_deps=1
    fi
  done
  if [[ ${missing_deps} -eq 1 ]]; then
      echo "ERROR: Missing required dependencies. See ${SOURCE_REPO} for installation instructions." >&2
      exit 1
  fi
  log debug "dependency_check" "All dependencies found"
}

show_help() {
    cat << EOF
craft.sh - Quick capture for Craft

USAGE:
    craft.sh [OPTIONS] <input>
    <command> | craft.sh [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -d, --debug         Enable debug logging
    -c, --code          Wrap <input> in a markdown code block

ARGUMENTS:
    <input>     Input text to capture (or via stdin/pipe)

EXAMPLES:
    craft.sh "Started work on x."
    echo "Some text" | craft.sh
    cat app.py | craft.sh --code
    pbpaste | craft.sh

CONFIG:
    ENV variables:   CRAFT_API_KEY, CRAFT_API_URL
    or config file:  ${CONFIG_FILE}

INFO:
    Source:   https://github.com/gdamberg/craft.sh/

EOF
}

# Logging function with 3 levels: debug, info, error
# Usage: log <level> <prefix> <message> [key=value...]
log() {
    local level="$1"
    local prefix="$2"
    shift 2
    local message="$*"
    
    # Skip debug messages if not in debug mode
    if [[ "${level}" == "debug" ]] && [[ "${LOG_LEVEL}" != "debug" ]]; then
        return 0
    fi
    
    # Format output based on level
    case "$level" in
        debug)
            echo -e "\033[2mDEBUG\033[0m [$prefix] $message" >&2
            ;;
        info)
            echo -e "\033[32mINFO\033[0m  [$prefix] $message"
            ;;
        error)
            echo -e "\033[31mERROR\033[0m [$prefix] $message" >&2
            ;;
    esac
}

# Create JSON payload for Craft API using jq
create_json() {
    local input_text="$1"
    local input_position="$2"
    local input_date="$3"
    
    log debug "create_json" "Building payload" "position=${input_position}" "date=${input_date}"
    
    # Use jq to create the JSON object
    # --null-input: start with null instead of reading input
    # --arg: pass shell variable as jq string variable
    local json_payload
    json_payload=$(jq --null-input --compact-output \
        --arg text "$input_text" \
        --arg position "$input_position" \
        --arg date "$input_date" \
        '{
            "blocks": [
                {
                    "type": "text",
                    "markdown": $text
                }
            ],
            "position": {
                "position": $position,
                "date": $date
            }
        }')
    
    log debug "create_json" "Payload created successfully"
    log debug "create_json" "${json_payload}" 
    echo "$json_payload"
}

# Load configuration from file
load_config() {
    # Check if API key and URL are already set in environment
    if [[ -n "${CRAFT_API_KEY}" ]] && [[ -n "${CRAFT_API_URL}" ]]; then
        log debug "load_config" "Using credentials from environment"
        return 0
    fi
    
    # Check if config file exists
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log error "load_config" "Config file not found" "path=${CONFIG_FILE}"
        log info "load_config" "Set CRAFT_API_KEY and CRAFT_API_URL environment variables or create config file"
        return 1
    fi
    
    log debug "load_config" "Loading config file" "path=${CONFIG_FILE}"
    
    # Source the config file
    # shellcheck disable=SC1090
    . "${CONFIG_FILE}"
    
    # Check if variables were loaded
    if [[ -z "${CRAFT_API_KEY}" ]]; then
        log error "load_config" "CRAFT_API_KEY not found in config file or environment"
        return 1
    fi
    
    if [[ -z "${CRAFT_API_URL}" ]]; then
        log error "load_config" "CRAFT_API_URL not found in config file or environment"
        return 1
    fi
    
    log debug "load_config" "Credentials loaded successfully"
    return 0
}

post_to_craft() {
    local api="$1"
    local payload="$2"
    
    # Validate inputs
    if [[ -z "${api}" ]]; then
        log error "post_to_craft" "API endpoint not specified"
        return 1
    fi
    
    if [[ -z "${payload}" ]]; then
        log error "post_to_craft" "Payload is empty"
        return 1
    fi
    
    # Validate payload is valid JSON
    if ! echo "${payload}" | jq empty 2>/dev/null; then
        log error "post_to_craft" "Invalid JSON payload"
        return 1
    fi
    
    local api_url="${CRAFT_API_URL}/${api}"
    log debug "post_to_craft" "Sending request" "url=${api_url}" "endpoint=${api}"
    
    # Make the API call with error handling
    local http_code
    local response
    local temp_file
    temp_file=$(mktemp)
    
    http_code=$(curl -s -w "%{http_code}" -o "${temp_file}" \
        -X POST "${api_url}" \
        -H "Authorization: Bearer ${CRAFT_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "${payload}")
    
    response=$(cat "${temp_file}")
    rm -f "${temp_file}"
    
    log debug "post_to_craft" "Response received" "http_code=${http_code}"
    
    # Check HTTP status code
    if [[ "${http_code}" -ge 200 ]] && [[ "${http_code}" -lt 300 ]]; then
        if [[ "${LOG_LEVEL}" == "debug" ]] && [[ -n "${response}" ]]; then
            log debug "post_to_craft" "${response}" | jq . -M 2>/dev/null || echo "${response}"
        fi
        return 0
    else
        log error "post_to_craft" "Request failed" "http_code=${http_code}" "response=${response}"
        return 1
    fi
}
# Main function that orchestrates the script
main() {
    log debug "main" "Starting craft.sh" "version=${VERSION}"
    
    # Check dependencies first
    dependency_check
    
    # local variables
    local input=""
    local api_action="blocks"
    local position="end"
    local date="today"
    local code_block=false
    
    # Parse arguments
    local input_args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--debug)
                LOG_LEVEL="debug"
                shift
                ;;
            -c|--code)
                code_block=true
                shift
                ;;
            -*)
                log error "main" "Unknown option" "option=$1"
                echo ""
                show_help
                exit 1
                ;;
            *)
                input_args+=("$1")
                shift
                ;;
        esac
    done

    # Load configuration
    if ! load_config; then
        log error "main" "Failed to load configuration"
        exit 1
    fi
    
    # Get input from arguments or stdin
    if [[ ${#input_args[@]} -gt 0 ]]; then
        # Input from command line arguments
        input="${input_args[*]}"
        log debug "main" "Input received from arguments" "length=${#input}"
    elif [[ ! -t 0 ]]; then
        # Input from pipe/stdin (when stdin is not a terminal)
        input=$(cat)
        log debug "main" "Input received from stdin/pipe" "length=${#input}"
    else
        # No input provided
        log error "main" "No input provided"
        echo ""
        show_help
        exit 1
    fi
    
    # Validate input is not empty
    if [[ -z "${input}" ]]; then
        log error "main" "Input is empty"
        exit 1
    fi
    
    log debug "main" "Processing input" "length=${#input}"
    if [ "$code_block" = true ]; then
        input="\`\`\`\n${input}\n\`\`\`"
    fi
    
    # Create JSON payload
    local json_payload
    json_payload=$(create_json "${input}" "${position}" "${date}")
    
    # Send to Craft API
    if post_to_craft "${api_action}" "${json_payload}"; then
      log debug "main" "Successfully posted to craft."
    else
        log error "Failed to post to Craft"
        exit 1
    fi
    
    log debug "end of craft.sh"
}

### Entry Point ###
main "$@"
