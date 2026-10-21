#!/usr/bin/env nu
# Full-Book In-Container Execution & Legacy Command Audit for Files/DataScienceNushell.md

def main [
    --chapter: string = "" # Optional chapter anchor filter (e.g., chapter-1-installation)
    --all                  # Execute all chapters across the entire book
    --mutate               # Run mutation check to verify failure detection
    --md-path: string = "" # Optional path to DataScienceNushell.md
] {
    let resolved_md = if ($md_path | is-not-empty) {
        $md_path
    } else if ("/Files/DataScienceNushell.md" | path exists) {
        "/Files/DataScienceNushell.md"
    } else {
        "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.md"
    }
    let raw_md = (open --raw $resolved_md)
    let lines = ($raw_md | lines)

    # 1. Audit zero references to forbidden legacy dsatcl commands
    let forbidden_regex = '\b(csvlook|csvstat|csvcut|csvgrep|csvsql|csvjoin|in2csv|sql2csv|dseq|dsatcl2e)\b'
    let legacy_hits = ($lines | enumerate | where ($it.item =~ $forbidden_regex))
    if ($legacy_hits | is-not-empty) and (not $mutate) {
        print $"ERROR: Found ($legacy_hits | length) forbidden legacy command references!"
        print ($legacy_hits | first 10 | to md)
        exit 1
    }

    # 2. Extract executable `nu` blocks grouped by chapter and `##` section
    mut in_block = false
    mut lang = ""
    mut start = 0
    mut buf = []
    mut cur_ch = "preamble"
    mut cur_h2 = "Intro"
    mut blocks = []

    for row in ($lines | enumerate) {
        let idx = $row.index + 1
        let line = $row.item
        if not $in_block {
            if ($line =~ '^# .*\{#(chapter-[^}]+)\}') {
                $cur_ch = ($line | parse --regex '\{#(?P<ch>[^}]+)\}' | first | get ch)
                $cur_h2 = $line
            } else if ($line =~ '^#{1,2} ') {
                $cur_h2 = $line
            } else if ($line | str starts-with "```") {
                $in_block = true
                $lang = ($line | str replace "```" "" | str trim)
                $start = $idx
                $buf = []
            }
        } else {
            if ($line | str trim) == "```" {
                $in_block = false
                if $lang == "nu" {
                    let code = ($buf | str join "\n")
                    let is_skip = (($code | str contains "╭─") or ($code | str contains "───┼───") or ($code | str contains "Error:") or ($code | str contains "# skip-docker-exec"))
                    let ch_match = if ($chapter | is-not-empty) { $cur_ch == $chapter } else { true }
                    if (not $is_skip) and $ch_match {
                        $blocks = ($blocks | append { ch: $cur_ch, sec: $"($cur_ch)::($cur_h2)", start: $start, end: $idx, code: $code })
                    }
                }
            } else {
                $buf = ($buf | append $line)
            }
        }
    }

    if $mutate {
        $blocks = ($blocks | first 5 | each { |b| $b | update code "non_existent_command_xyz_123" })
    }

    $blocks | save -f /tmp/test_md_blocks.json

    let res = (^sudo -n /usr/bin/docker run --rm
        -v "/tmp/test_md_blocks.json:/tmp/test_md_blocks.json"
        -v "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/data:/data"
        dsin:latest -c '
            let blocks = (open /tmp/test_md_blocks.json)
            mut chunks = []
            mut cur_chunk = []
            mut cur_sec = ""
            mut cur_ch = ""
            for b in $blocks {
                let redefines_greet = (($b.code =~ "(?m)^def (greet|\"str mycommand\")") and ($cur_chunk | any { |x| $x.code =~ "(?m)^def (greet|\"str mycommand\")" }))
                if ($b.sec != $cur_sec) or $redefines_greet {
                    if ($cur_chunk | is-not-empty) {
                        $chunks = ($chunks | append { ch: $cur_ch, sec: $cur_sec, items: $cur_chunk })
                    }
                    $cur_sec = $b.sec
                    $cur_ch = $b.ch
                    $cur_chunk = [$b]
                } else {
                    $cur_chunk = ($cur_chunk | append $b)
                }
            }
            if ($cur_chunk | is-not-empty) {
                $chunks = ($chunks | append { ch: $cur_ch, sec: $cur_sec, items: $cur_chunk })
            }
            mut passed_blocks = 0
            mut chunk_failures = []
            for c in $chunks {
                let workdir = match $c.ch {
                    "chapter-1-introduction" => "/data"
                    "chapter-2-installation" => "/data"
                    "chapter-3-nushell-fundamentals" | "chapter-2-introduction" => "/data/ch03"
                    "chapter-4-programming-cli-tools" | "chapter-3-programming-cli-tools" => "/data/ch04"
                    "chapter-5-data-acquisition" | "chapter-4-obtaining-data" => "/data/ch05"
                    "chapter-6-data-cleaning" | "chapter-5-scrubbing-data" => "/data/ch06"
                    "chapter-7-data-exploration" | "chapter-6-exploring-data" | "chapter-7-exploring-data" => "/data/ch07"
                    "chapter-8-parallel-pipelines" | "chapter-7-parallel-pipelines" => "/data/ch08"
                    "chapter-9-polyglot-modeling" | "chapter-8-modeling-data" | "chapter-9-modeling-data" => "/data/ch09"
                    _ => "/data"
                }
                let body = ($c.items | each { |b| $"# --- line ($b.start) ---\n($b.code)\nprint \"\n__BLOCK_OK_($b.start)__\"" } | str join "\n\n")
                let script = $"plugin use polars\nuse ~/.config/nushell/nu_modules/dsin_tools.nu *\ncd ($workdir)\n($body)"
                $script | save -f /tmp/sec_run.nu
                let r = (timeout 45s nu --plugin-config ~/.config/nushell/plugin.msgpackz /tmp/sec_run.nu | complete)
                let ok_count = ($r.stdout | lines | where ($it | str contains "__BLOCK_OK_") | length)
                $passed_blocks = $passed_blocks + $ok_count
                if $r.exit_code != 0 or ($ok_count < ($c.items | length)) {
                    let err_msg = ($r.stderr | lines | where ($it | str contains "×") or ($it | str contains "Error:") or ($it | str contains "x ") | str join " | ")
                    $chunk_failures = ($chunk_failures | append { sec: $c.sec, total: ($c.items | length), ok: $ok_count, err: $err_msg })
                }
            }
            print $"Total executable blocks passed: ($passed_blocks) / ($blocks | length)"
            if ($chunk_failures | is-not-empty) {
                print ($chunk_failures | to md)
                exit 1
            }
        ' | complete)

    print $res.stdout
    if $mutate {
        if $res.exit_code != 0 {
            print "Mutation check PASSED: Corrupted blocks were caught by in-container execution."
            exit 0
        } else {
            print "Mutation check FAILED: Corrupted blocks were not caught!"
            exit 1
        }
    } else {
        if $res.exit_code != 0 {
            print $res.stderr
            exit 1
        }
    }
}
