#!/bin/sh
# vim:set sts=2 sw=2 tw=0 et:

GIT_REPO="git@github.com:vim-jp/vimdoc-ja.git"
GIT_BRANCH="master2-test"
GIT_NAME="vimdoc-ja system"
GIT_EMAIL="vimdoc-ja@vim-jp.org"

WORKDIR="target"
BRANCHDIR="${WORKDIR}/${GIT_BRANCH}"

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

# work in BRANCHDIR.
(
  echo "Make changes in \"${BRANCHDIR}\""
  cd "${BRANCHDIR}"
  # TODO: update buffers
  touch test.txt
  ts=`date "+%Y/%m/%d %H:%M:%S%z"`
  echo "${ts}" >> test.txt
  if [ -e foo.txt ] ; then
    rm -f foo.txt
    touch bar.txt
    echo "${ts} foo->bar" >> bar.txt
  elif [ -e bar.txt ] ; then
    rm -f bar.txt
    touch foo.txt
    echo "${ts} bar->foo" >> foo.txt
  fi
)

# Commit changes
(
  echo "Register changes and push it to \"${GIT_REPO}\""
  sha1hash=`git show --pretty="format:%H" | head -1`
  commit_message="Deployed ${sha1hash} from ${GIT_BRANCH} in ${GIT_REPO}"
  cd "${BRANCHDIR}"
  host=`hostname`
  git config user.name "${GIT_NAME}"
  git config user.email "${GIT_EMAIL}"
  git add --all .
  git commit -m "${commit_message}"
  git push || exit 1
)
