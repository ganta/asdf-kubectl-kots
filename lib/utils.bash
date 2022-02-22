#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -euo pipefail

GH_REPO="https://github.com/replicatedhq/kots"
TOOL_NAME="kubectl-kots"
TOOL_DISPLAY_NAME="Replicated KOTS"

fail() {
  echo -e "asdf-${TOOL_NAME}: $*"
  exit 1
}

curl_opts=(-fsSL)

if [[ -n ${GITHUB_API_TOKEN:-} ]]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token ${GITHUB_API_TOKEN}")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "${GH_REPO}" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//'
}

list_all_versions() {
  list_github_tags |
    grep -v -- "-nightly" |
    grep -v -- "-beta"
}

download_release() {
  local version="$1"
  local filename="$2"
  local platform arch url

  platform="$(get_platform)"
  arch="$(get_arch)"

  # KOTS v1.59.2 and later are macOS universal binaries, and the archive name has been changed.
  if [[ ${platform} == "darwin" ]]; then
    if compare_version_greater_than_or_equal_to "${version}" "1.59.2"; then
      arch="all"
    else
      arch="amd64"
    fi
  fi

  url="${GH_REPO}/releases/download/v${version}/kots_${platform}_${arch}.tar.gz"

  echo "* Downloading ${TOOL_DISPLAY_NAME} release $version..."
  curl "${curl_opts[@]}" -o "${filename}" -C - "${url}" || fail "Could not download ${url}"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [[ ${install_type} != "version" ]]; then
    fail "asdf-${TOOL_NAME} supports release installs only"
  fi

  (
    mkdir -p "${install_path}"
    cp -a "${ASDF_DOWNLOAD_PATH}"/* "${install_path}/"

    mkdir -p "${install_path}/bin"
    mv "${install_path}/kots" "${install_path}/bin/kubectl-kots" ||
      fail "Expected ${install_path}/kots to exit."

    test -x "${install_path}/bin/${TOOL_NAME}" ||
      fail "Expected ${install_path}/bin/${TOOL_NAME} to be executable."

    echo "${TOOL_DISPLAY_NAME} ${version} installation was successful!"
  ) || (
    rm -rf "${install_path}"
    fail "An error occurred while installing ${TOOL_DISPLAY_NAME} ${version}."
  )
}

get_platform() {
  local platform

  platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  echo -n "${platform}"
}

get_arch() {
  local arch

  arch="$(uname -m)"

  if [[ ${arch} == "x86_64" ]]; then
    arch="amd64"
  fi

  echo -n "${arch}"
}

compare_version_greater_than_or_equal_to() {
  local version_a="$1"
  local version_b="$2"

  if [[ ${version_a} == "${version_b}" ]]; then
    return 0
  fi

  older_version=$(printf "%s\n%s" "${version_a}" "${version_b}" | sort_versions | head -1)

  if [[ ${older_version} == "${version_b}" ]]; then
    return 0
  else
    return 1
  fi
}
