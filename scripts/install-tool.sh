#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

case $1 in

  "cli")
    GITHUBCLI_VERSION="$2"
    wget -O- -nv https://github.com/cli/cli/releases/download/v${GITHUBCLI_VERSION}/gh_${GITHUBCLI_VERSION}_linux_amd64.tar.gz | tar -xzO gh_${GITHUBCLI_VERSION}_linux_amd64/bin/gh > /usr/bin/gh
    chmod +x /usr/bin/gh
    ;;

  "neon")
    wget -O/usr/bin/neon -nv https://sweetohm.net/dist/neon/neon-linux-amd64
    chmod +x /usr/bin/neon
    ;;

  "svu")
    SVU_VERSION="$2"
    wget -O- -nv https://install.goreleaser.com/github.com/caarlos0/svu.sh | sh -s -- -b  /usr/bin v${SVU_VERSION}
    ;;

  "venom")
    VENOM_VERSION="$2"
    wget -O /usr/bin/venom -nv https://github.com/ovh/venom/releases/download/v${VENOM_VERSION}/venom.linux-amd64
    chmod +x /usr/bin/venom
    ;;

  "changie")
    CHANGIE_VERSION="$2"
    wget -O- -nv https://github.com/miniscruff/changie/releases/download/v${CHANGIE_VERSION}/changie_${CHANGIE_VERSION}_linux_amd64.tar.gz | tar -xzO changie > /usr/bin/changie
    chmod +x /usr/bin/changie
    ;;

  *)
    echo "Unknown tool : $1"
    ;;
esac

# invalidate cache for welcome page
cache -d -- bash ~/welcome.sh
