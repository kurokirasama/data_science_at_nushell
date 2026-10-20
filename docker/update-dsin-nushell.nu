#!/usr/bin/env nu
# Update the Nushell version inside the dsin Docker image, rebuild, test, and optionally push.

export def main [
  --version(-v): string # Target Nushell version (defaults to latest GitHub release)
  --check(-c)           # Only check current vs latest Nushell version without rebuilding
  --push(-p)            # Push updated dsin image tags to GHCR (ghcr.io/kurokirasama/dsin) and Docker Hub
]: nothing -> record {
  let repo_root = ($env.FILE_PWD | path dirname)
  let dockerfile = $"($repo_root)/docker/Dockerfile"

  let current_ver = (
    open --raw $dockerfile
    | parse --regex 'ARG NUSHELL_VERSION="(?<ver>[^"]+)"'
    | first
    | get ver
  )

  let target_ver = if ($version | is-not-empty) {
    $version | str trim -c 'v'
  } else {
    try {
      http get https://api.github.com/repos/nushell/nushell/releases/latest
      | get tag_name
      | str trim -c 'v'
    } catch {
      $current_ver
    }
  }

  let report = {
    current_version: $current_ver
    target_version: $target_ver
    needs_update: ($current_ver != $target_ver)
    dockerfile: $dockerfile
  }

  if $check {
    print ($report | to json)
    return $report
  }

  open --raw $dockerfile
  | str replace -r 'ARG NUSHELL_VERSION="[^"]+"' $"ARG NUSHELL_VERSION=\"($target_ver)\""
  | save -f $dockerfile

  ^sudo -n docker build -t dsin:latest -t $"dsin:($target_ver)" -t ghcr.io/kurokirasama/dsin:latest -t $"ghcr.io/kurokirasama/dsin:($target_ver)" -t kurokirasama/dsin:latest -t $"kurokirasama/dsin:($target_ver)" -f $dockerfile $"($repo_root)/docker"

  if $push {
    if (which gh | is-not-empty) {
      let tok = (do -i { ^gh auth token } | complete | get stdout | str trim)
      if ($tok | is-not-empty) {
        $tok | ^sudo -n docker login ghcr.io -u kurokirasama --password-stdin
      }
    }
    ^sudo -n docker push ghcr.io/kurokirasama/dsin:latest
    ^sudo -n docker push $"ghcr.io/kurokirasama/dsin:($target_ver)"
  }

  $report | insert rebuilt true | insert pushed $push
}
