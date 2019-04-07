#!/usr/bin/env bash

################################################################################
# Run global git hooks, before running local ones                              #
################################################################################

[[ "${DEBUG}" == 'true' ]] && set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

echo "$(tput bold)git-global-hooks install$(tput sgr0)"

dir_is_empty() {
  shopt -s nullglob
  shopt -s dotglob
  readonly CHECK_FILES=(./*)
  readonly NUM_FILES=${#CHECK_FILES[*]}
  shopt -u nullglob
  shopt -u dotglob
  [[ $NUM_FILES -eq 0 ]]
}

if ! dir_is_empty
then
  read -p "$(tput setaf 3)warning$(tput sgr0) This installer will create global git hook files in $(tput setaf 3)$(pwd)$(tput sgr0). Would you like to proceed? (y/$(tput bold)N$(tput sgr0)) " -n 1 -r
  echo ""

  # User didn't explicitly approve
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi
fi

trap 'rm -f $TEMP_PATH' EXIT

readonly GIT_HOOKS=(applypatch-msg commit-msg post-applypatch post-checkout post-commit post-merge post-receive post-rewrite post-update pre-applypatch pre-auto-gc pre-commit pre-push pre-rebase pre-receive prepare-commit-msg push-to-checkout update)
readonly TEMP_PATH=$(mktemp)
readonly TEMPLATE=$(cat <<'END_OF_TEMPLATE'
#!/usr/bin/env bash

########################################################
# DON'T EDIT THIS FILE. EDIT THE .global-FILE INSTEAD. #
########################################################

[[ "${DEBUG}" == 'true' ]] && set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

readonly HOOK="$(basename $0)"
readonly GIT_DIR="${GIT_DIR:-.git/}" # ATTN: Has trailing slash
readonly GLOBAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly GLOBAL_HOOK="${GLOBAL_DIR}/$HOOK.global.sh"
readonly LOCAL_DIR="$(pwd)"
readonly LOCAL_HOOK="${LOCAL_DIR}/${GIT_DIR}hooks/$HOOK"

if [[ -s "$GLOBAL_HOOK" ]]
then
  echo "🌍  $HOOK hook"
  "$GLOBAL_HOOK"
fi

if [[ -s "$LOCAL_HOOK" ]]
then
  echo "🏠  $HOOK hook"
  "$LOCAL_HOOK"
fi
END_OF_TEMPLATE
)

echo "📄  Copying template..."
# Use an intermediate file and copy it, rather than overwriting the destination,
# so as not to clobber pre-existing hooks.
echo "${TEMPLATE}" > "${TEMP_PATH}"
for GIT_HOOK in "${GIT_HOOKS[@]}";
do
  cp "${TEMP_PATH}" "${GIT_HOOK}"
  touch "${GIT_HOOK}".global.sh
  chmod +x "${GIT_HOOK}".global.sh
done

echo "🔗  Setting global hooks path to $(tput setaf 3)$(pwd)$(tput sgr0)..."
git config --global core.hooksPath "$(pwd)"

echo "$(tput setaf 2)success$(tput sgr0) Installed global hooks."
echo "$(tput setaf 4)info$(tput sgr0) Create global hooks, by modifying the *.global.sh-files in $(tput setaf 3)$(pwd)$(tput sgr0)."
echo "✨  Done."
