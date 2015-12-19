CONFIGFILE=`dirname $0`/update-config.sh

. "${CONFIGFILE}"

if [ x"${GIT_REPO}" = "x" ] ; then
  echo "GIT_REPO is missing in \"${CONFIGFILE}\"" && exit 1
fi
if [ x"${GIT_NAME}" = "x" ] ; then
  echo "GIT_NAME is missing in \"${CONFIGFILE}\"" && exit 1
fi
if [ x"${GIT_EMAIL}" = "x" ] ; then
  echo "GIT_EMAIL is missing in \"${CONFIGFILE}\"" && exit 1
fi

setup() {
  GIT_BRANCH="$1" ; shift
  if [ x"${GIT_BRANCH}" = "x" ] ; then
    echo "GIT_BRANCH is required"
    exit 1
  fi

  WORKDIR="target"
  BRANCHDIR="${WORKDIR}/${GIT_BRANCH}"

  # FIXME: exit if failed.
  SHA1HASH=`git show --pretty="format:%H" | head -1`

  # Prepare and clean up working directories.
  if [ ! -e "${WORKDIR}" ] ; then
    mkdir -p "${WORKDIR}"
  fi
  if [ -e "${BRANCHDIR}" ] ; then
    rm -rf "${BRANCHDIR}"
  fi

  # Checkout a target branch.
  echo "Checking out \"${GIT_BRANCH}\" from \"${GIT_REPO}\""
  git clone -q -b "${GIT_BRANCH}" --depth 5 "${GIT_REPO}" "${BRANCHDIR}" || exit 1

  echo "Make changes in \"${BRANCHDIR}\""
  PARENTDIR=`pwd`
  cd "${BRANCHDIR}"
  CHILDDIR=`pwd`
  cd "${PARENTDIR}"
}

teardown() {
  HASH_PREFIX=$1 ; shift
  cd "${CHILDDIR}"
  git config user.name "${GIT_NAME}"
  git config user.email "${GIT_EMAIL}"
  git add --all .
  if ! git diff --quiet HEAD ; then
    echo "Register changes and push it to \"${GIT_REPO}\""
    commit_message="Deployed ${HASH_PREFIX}${SHA1HASH} by `hostname`"
    git commit -m "${commit_message}"
    git push || exit 1
  else
    echo "No changes"
  fi
}
