#!/usr/bin/env nu
# TDD Verification Suite for Phase 1: Repository Scaffolding, Conductor Setup & Privacy Isolation

use std assert

export def run-scaffold-checks [target_dir: string = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell"]: nothing -> table {
  mut results = []

  # 1. Target repository directory exists
  let dir_exists = ($target_dir | path exists)
  $results ++= [{ check: "repo_dir_exists", passed: $dir_exists, detail: $target_dir }]

  # 2. Conductor core files exist and reference DataScienceAtNushell / dsin
  let conductor_files = ["index.md", "product.md", "product-guidelines.md", "tech-stack.md", "workflow.md", "tracks.md"]
  let conductor_ok = $conductor_files | all { |f| ($"($target_dir)/conductor/($f)" | path exists) }
  $results ++= [{ check: "conductor_core_files_exist", passed: $conductor_ok, detail: ($conductor_files | str join ", ") }]

  let product_updated = if ($"($target_dir)/conductor/product.md" | path exists) {
    let txt = open --raw $"($target_dir)/conductor/product.md"
    ($txt | str contains "Data Science at Nushell") and ($txt | str contains "DataScienceNushell.md")
  } else { false }
  $results ++= [{ check: "conductor_product_adapted", passed: $product_updated, detail: "References Data Science at Nushell and DataScienceNushell.md" }]

  let tech_updated = if ($"($target_dir)/conductor/tech-stack.md" | path exists) {
    let txt = open --raw $"($target_dir)/conductor/tech-stack.md"
    ($txt | str contains "dsin") and (not ($txt | str contains "datasciencetoolbox/dsatcl2e"))
  } else { false }
  $results ++= [{ check: "conductor_tech_stack_adapted", passed: $tech_updated, detail: "References dsin image without dsatcl2e dependency" }]

  # 3. Conductor archive/ is empty and tracks/ only has the mirrored track
  let archive_empty = if ($"($target_dir)/conductor/archive" | path exists) {
    (ls $"($target_dir)/conductor/archive" | is-empty)
  } else { false }
  $results ++= [{ check: "conductor_archive_clean", passed: $archive_empty, detail: "conductor/archive is empty" }]

  let mirrored_track = ($"($target_dir)/conductor/tracks/port_course_to_nushell_20261020/spec.md" | path exists)
  $results ++= [{ check: "conductor_track_mirrored", passed: $mirrored_track, detail: "port_course_to_nushell_20261020 mirrored" }]

  # 4. Root docs exist and are adapted
  let root_docs = ["GEMINI.md", "AGENTS.md", "CLAUDE.md", "README.md"]
  let root_docs_ok = $root_docs | all { |f|
    let p = $"($target_dir)/($f)"
    if ($p | path exists) {
      let c = open --raw $p
      ($c | str contains "DataScienceNushell") or ($c | str contains "Data Science at Nushell")
    } else { false }
  }
  $results ++= [{ check: "root_docs_adapted", passed: $root_docs_ok, detail: "GEMINI.md, AGENTS.md, CLAUDE.md, README.md adapted" }]

  # 5. Files/ assets & DataScienceNushell.md exist and PDF compiled
  let md_exists = ($"($target_dir)/Files/DataScienceNushell.md" | path exists)
  let data_exists = ($"($target_dir)/Files/data" | path exists)
  let pdf_exists = if ($"($target_dir)/Files/DataScienceNushell.pdf" | path exists) {
    (ls $"($target_dir)/Files/DataScienceNushell.pdf" | first | get size) > 10kb
  } else { false }
  $results ++= [{ check: "files_and_md_copied", passed: ($md_exists and $data_exists), detail: "Files/DataScienceNushell.md and Files/data present" }]
  $results ++= [{ check: "baseline_pdf_compiled", passed: $pdf_exists, detail: "Files/DataScienceNushell.pdf compiled (>10KB)" }]

  # 6. Git repository, remote, .gitignore, and local-only private branch isolation
  let git_exists = ($"($target_dir)/.git" | path exists)
  let remote_ok = if $git_exists {
    let rem = (do -i { ^git -C $target_dir remote get-url origin } | complete | get stdout | str trim)
    $rem == "git@github.com:kurokirasama/data_science_at_nushell.git"
  } else { false }
  $results ++= [{ check: "git_remote_configured", passed: $remote_ok, detail: "origin == git@github.com:kurokirasama/data_science_at_nushell.git" }]

  let gitignore_ok = if ($"($target_dir)/.gitignore" | path exists) {
    let gi = open --raw $"($target_dir)/.gitignore"
    ["conductor/", "GEMINI.md", "AGENTS.md", "CLAUDE.md", "todos.md"] | all { |pat| $gi | str contains $pat }
  } else { false }
  $results ++= [{ check: "gitignore_excludes_agentic", passed: $gitignore_ok, detail: ".gitignore excludes conductor/, GEMINI.md, AGENTS.md, CLAUDE.md, todos.md" }]

  let private_branch_guard = if $git_exists {
    let push_rem = (do -i { ^git -C $target_dir config --get branch.private.pushRemote } | complete | get stdout | str trim)
    $push_rem == "no_push"
  } else { false }
  $results ++= [{ check: "private_branch_push_guard", passed: $private_branch_guard, detail: "branch.private.pushRemote == no_push" }]

  let main_clean_of_agentic = if $git_exists {
    let tracked = (do -i { ^git -C $target_dir ls-tree -r --name-only main } | complete | get stdout | lines)
    not ($tracked | any { |f| ($f | str starts-with "conductor/") or ($f in ["GEMINI.md", "AGENTS.md", "CLAUDE.md", "todos.md"]) })
  } else { false }
  $results ++= [{ check: "main_branch_zero_agentic_files", passed: $main_clean_of_agentic, detail: "Zero agentic files tracked in main branch" }]

  $results
}

def main [target_dir: string = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell"] {
  let res = run-scaffold-checks $target_dir
  print ($res | table -e)
  let failed = $res | where not $it.passed
  if ($failed | is-not-empty) {
    error make { msg: $"($failed | length) scaffold check\(s\) failed!" }
  }
  print "All Phase 1 scaffold and privacy checks PASSED!"
}
