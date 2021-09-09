#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

print_version() {
  AVAIL=$(glast $2/$3 | sed -e 's/^.*v//')
  ALIAS=${5:-$3}
  [ "${AVAIL}" == "$4" ] && printf "├── %-15s %10s ✅\n" "$1" "$4" # ✔️ not working
  [ "$4" == "n/a" ] && printf "├── %-15s %10s ❌ run 'up ${ALIAS} ${AVAIL}' to install latest version\n" "$1" "$4" && return 0
  [ "${AVAIL}" != "$4" ] && printf "├── %-15s %10s 🆕 run 'up ${ALIAS} ${AVAIL}' to update to latest version\n" "$1" "$4" && return 0
  return 0
}

get_githubcli_version() {
  gh --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo -n "n/a" && return 0
}

get_neon_version() {
  neon --version 2>/dev/null || echo -n "n/a" && return 0
}

get_svu_version() {
  if svu --version >/dev/null 2>&1; then
    svu --version 2>&1 >/dev/null | cut -d' ' -f3
    return 0
  fi
  echo "n/a"
}

get_venom_version() {
  venom version 2>/dev/null | cut -d' ' -f3 | sed -e 's/^v//' || echo -n "n/a" && return 0
}

get_changie_version() {
  changie -v 2>/dev/null | cut -d' ' -f3 | sed -e 's/^v//' || echo -n "n/a" && return 0
}

figlet -c Rust Devcontainer

(
  source /etc/os-release
  printf "%-16s %13s " "${NAME}" "v${VERSION_ID}"
  if [[ "${NAME}" == "Debian GNU/Linux" ]]; then
    echo "✅"
  else
    LATEST_ALPINE_VERSION=$(dlast alpine)
    [[ "${LATEST_ALPINE_VERSION}" == "${VERSION_ID}" ]] && echo "✅" || echo "🆕 new alpine version available v${LATEST_ALPINE_VERSION}"
  fi
)

DOCKER_CLI_VERSION=$(docker version -f '{{.Client.Version}}' 2>/dev/null || :)
DOCKER_CLI_VERSION_LATEST=$(dlast docker)
printf "├── %-15s %10s " "Docker Client" "v${DOCKER_CLI_VERSION}"
[[ "${DOCKER_CLI_VERSION_LATEST}" == "${DOCKER_CLI_VERSION}" ]] && echo "✅" || echo "🆕 new version available v${DOCKER_CLI_VERSION_LATEST}, run 'sudo up-docker' to update"

DOCKER_COMPOSE_VERSION=$(sudo docker-compose --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || :)
DOCKER_COMPOSE_VERSION_LATEST=$(dlast -r docker compose)
printf "├── %-15s %10s " "Docker Compose" "v${DOCKER_COMPOSE_VERSION}"
[[ "${DOCKER_COMPOSE_VERSION_LATEST}" == "${DOCKER_COMPOSE_VERSION}" ]] && echo "✅" || echo "🆕 new version available v${DOCKER_COMPOSE_VERSION_LATEST}, run 'sudo up-docker-compose' to update"

GIT_VERSION=$(git --version | cut -d' ' -f3 || :)
GIT_VERSION_LATEST=$(dlast -f '^v[0-9]\+\(\.[0-9]\+\)\+$' -r alpine git | sed -e 's/^v//')
printf "├── %-15s %10s " "Git Client" "v${GIT_VERSION}"
[[ "${GIT_VERSION_LATEST}" == "${GIT_VERSION}" ]] && echo "✅" || echo "🆕 new version available v${GIT_VERSION_LATEST}"

ZSH_VERSION=$(zsh --version | cut -d' ' -f2 || :)
ZSH_VERSION_LATEST=$(dlast -r zshusers zsh)
printf "├── %-15s %10s " "Zsh" "v${ZSH_VERSION}"
[[ "${ZSH_VERSION_LATEST}" == "${ZSH_VERSION}" ]] && echo "✅" || echo "🆕 new version available v${ZSH_VERSION_LATEST}"

if [ "${1-x}" == "--check-all-versions" ]; then
    echo
    echo "CI tools"
    print_version "Venom" "ovh" "venom" "$(get_venom_version)"
    print_version "Neon" "c4s4" "neon" "$(get_neon_version)"
    print_version "SVU" "caarlos0" "svu" "$(get_svu_version)"
    print_version "Changie" "miniscruff" "changie" "$(get_changie_version)"
    print_version "Github CLI" "cli" "cli" "$(get_githubcli_version)"
fi
echo
