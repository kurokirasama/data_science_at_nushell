#!/usr/bin/env nu
# Master Mutation Testing Runner for Data Science at Nushell

def main [] {
    let repo = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell"
    cd $repo

    mut results = []

    let m1 = (nu tests/test_repo_scaffold.nu /tmp/nonexistent_mutant_repo | complete)
    $results = ($results | append { suite: "test_repo_scaffold.nu (mutant repo)", killed: ($m1.exit_code != 0) })

    let m2 = (nu tests/test_dsin_container.nu dsin:nonexistent_mutant_tag | complete)
    $results = ($results | append { suite: "test_dsin_container.nu (mutant tag)", killed: ($m2.exit_code != 0) })

    let m3 = (^sudo -n docker run --rm -v $"($repo)/Files:/data" -v $"($repo)/tests:/tests" dsin:latest -c "nu /tests/test_modeling_pipelines.nu --mutate" | complete)
    $results = ($results | append { suite: "test_modeling_pipelines.nu --mutate", killed: ($m3.exit_code == 0) })

    let m4 = (nu tests/test_md_execution.nu --mutate | complete)
    $results = ($results | append { suite: "test_md_execution.nu --mutate", killed: ($m4.exit_code == 0) })

    print ($results | to md)
    let killed_count = ($results | where killed == true | length)
    let score = (($killed_count / ($results | length)) * 100 | math round -p 1)
    print $"Mutation Score: ($score)% \(($killed_count)/($results | length) suites killed all mutants\)"
    if $score < 70.0 {
        exit 1
    }
}
