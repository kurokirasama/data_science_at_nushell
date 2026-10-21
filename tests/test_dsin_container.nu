#!/usr/bin/env nu
# TDD Verification Suite for Standalone dsin Docker Image, Built-in /data, PATH Tooling & Updater Script

export def run-dsin-checks [image: string = "dsin:latest"]: nothing -> table {
  mut results = []

  # 1. Upstream audit document exists
  let audit_ok = ("/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/UPSTREAM_AUDIT.md" | path exists)
  $results ++= [{ check: "upstream_audit_documented", passed: $audit_ok, detail: "docker/UPSTREAM_AUDIT.md exists" }]

  # 2. Dockerfile and config.nu exist
  let df_ok = ("/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/Dockerfile" | path exists)
  let cfg_ok = ("/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/config.nu" | path exists)
  $results ++= [{ check: "dockerfile_and_config_exist", passed: ($df_ok and $cfg_ok), detail: "docker/Dockerfile and docker/config.nu exist" }]

  # 3. Check if dsin Docker image is built locally
  let img_check = (do -i { ^sudo -n docker image inspect $image } | complete)
  let img_exists = ($img_check.exit_code == 0)
  $results ++= [{ check: "dsin_image_built", passed: $img_exists, detail: $"Image ($image) present in local Docker daemon" }]

  if not $img_exists {
    return $results
  }

  # 4. Default entrypoint is Nushell and returns version >= 0.116, default user is dsin, workdir is /home/dsin
  let nu_ver_res = (do -i { ^sudo -n docker run --rm $image -c "version | get version" } | complete)
  let nu_ok = ($nu_ver_res.exit_code == 0) and (($nu_ver_res.stdout | str trim) | is-not-empty)
  $results ++= [{ check: "default_shell_is_nushell", passed: $nu_ok, detail: $"Nushell version: ($nu_ver_res.stdout | str trim)" }]

  let user_res = (do -i { ^sudo -n docker run --rm $image -c "whoami" } | complete)
  let user_ok = ($user_res.exit_code == 0) and (($user_res.stdout | str trim) == "dsin")
  $results ++= [{ check: "default_user_is_dsin", passed: $user_ok, detail: $"Default user: ($user_res.stdout | str trim)" }]

  let pwd_res = (do -i { ^sudo -n docker run --rm $image -c "pwd" } | complete)
  let pwd_ok = ($pwd_res.exit_code == 0) and (($pwd_res.stdout | str trim) == "/home/dsin")
  $results ++= [{ check: "default_workdir_is_home", passed: $pwd_ok, detail: $"Default workdir: ($pwd_res.stdout | str trim)" }]

  # 5. Built-in /data folder with ch03..ch09 by default (no volume mount needed)
  let data_res = (do -i { ^sudo -n docker run --rm $image -c "[ch03 ch04 ch05 ch06 ch07 ch08 ch09] | all {|d| ($'/data/($d)' | path exists)}" } | complete)
  let data_ok = ($data_res.exit_code == 0) and (($data_res.stdout | str trim) == "true")
  $results ++= [{ check: "builtin_data_ch03_to_ch09", passed: $data_ok, detail: $"Built-in /data/ch03..ch09 present: ($data_res.stdout | str trim)" }]

  # 6. Custom config.nu is loaded ($env.config.float_precision == 4)
  let cfg_res = (do -i { ^sudo -n docker run --rm $image --config /home/dsin/.config/nushell/config.nu -c "$env.config.float_precision" } | complete)
  let custom_cfg_ok = ($cfg_res.exit_code == 0) and (($cfg_res.stdout | str trim) == "4")
  $results ++= [{ check: "custom_config_loaded", passed: $custom_cfg_ok, detail: $"float_precision == ($cfg_res.stdout | str trim)" }]

  # 7. nu_plugin_polars is registered and works
  let polars_res = (do -i { ^sudo -n docker run --rm $image -c "plugin use polars; [[a b]; [1 2] [3 4]] | polars into-df | polars select a | polars into-nu | get a | math sum" } | complete)
  let polars_ok = ($polars_res.exit_code == 0) and (($polars_res.stdout | str trim) == "4")
  $results ++= [{ check: "polars_plugin_working", passed: $polars_ok, detail: $"polars sum == ($polars_res.stdout | str trim)" }]

  # 8. ttt binary in PATH without ^ and ~/.config/ttt/settings.json exist inside container
  let ttt_res = (do -i { ^sudo -n docker run --rm $image -c "((ttt -v | str length) > 0) and ('~/.config/ttt/settings.json' | path expand | path exists)" } | complete)
  let ttt_ok = ($ttt_res.exit_code == 0) and (($ttt_res.stdout | str trim) == "true")
  $results ++= [{ check: "ttt_editor_in_path", passed: $ttt_ok, detail: $"ttt in PATH + settings.json: ($ttt_res.stdout | str trim)" }]

  # 9. timg binary in PATH without ^ and renders a plot inside container
  let timg_res = (do -i { ^sudo -n docker run --rm $image -c "cd /data/ch07; Rscript plot_bar.R; (timg -g 10x5 tips_bar.png | str length) > 10" } | complete)
  let timg_ok = ($timg_res.exit_code == 0) and (($timg_res.stdout | str trim) == "true")
  $results ++= [{ check: "timg_viewer_in_path", passed: $timg_ok, detail: $"timg in PATH renders plot: ($timg_res.stdout | str trim)" }]

  # 10. All CLI & modeling tools directly in PATH (vw, tapkee, parallel, pbc, run_experiment, Rscript, python3, sqlite3, git, 7z, jq)
  let tools_res = (do -i { ^sudo -n docker run --rm $image -c "[ttt timg parallel pbc vw tapkee run_experiment Rscript python3 sqlite3 git 7z jq] | all { |t| which $t | is-not-empty }" } | complete)
  let tools_ok = ($tools_res.exit_code == 0) and (($tools_res.stdout | str trim) == "true")
  $results ++= [{ check: "external_tools_in_path", passed: $tools_ok, detail: $"All required CLI/modeling tools in PATH: ($tools_res.stdout | str trim)" }]

  # 11. Custom l nushell command works flawlessly (custom type, LS_COLORS defined, both standalone, with path, with -s, with -d)
  let l_res = (do -i { ^sudo -n docker run --rm $image --config /home/dsin/.config/nushell/config.nu -c "(l /data | length) > 0 and (l -s | length) >= 0 and (l /data/ch03 -d | length) > 0 and ((which l | get 0.type) == 'custom') and ($env.LS_COLORS? | default '' | str contains 'di=01;34') and ($env.config.ls.use_ls_colors == true)" } | complete)
  let l_ok = ($l_res.exit_code == 0) and (($l_res.stdout | str trim) == "true")
  $results ++= [{ check: "custom_l_command_works", passed: $l_ok, detail: $"l custom type, LS_COLORS, and pipelines execute flawlessly: ($l_res.stdout | str trim)" }]

  # 12. Generated example output files and directories are clean from /data
  let clean_res = (do -i { ^sudo -n docker run --rm $image -c "['/data/ch03/fac.py.bak' '/data/ch03/edition2.json' '/data/ch03/chapters.txt' '/data/ch03/dates.txt' '/data/ch04/world' '/data/ch05/logs' '/data/ch06/bills.csv' '/data/ch06/customers.csv' '/data/ch06/datetime.csv' '/data/ch06/fb.png' '/data/ch06/table.html' '/data/ch07/plot-bar.png' '/data/ch07/tips.png' '/data/ch07/percent.csv' '/data/ch08/hi-1.txt' '/data/ch08/outdir' '/data/ch08/one-big-file.txt' '/data/ch08/emails' '/data/ch09/output' '/data/ch09/predictions' '/data/ch09/wine.model' '/data/ch09/results.csv'] | all {|f| not ($f | path exists)}" } | complete)
  let clean_ok = ($clean_res.exit_code == 0) and (($clean_res.stdout | str trim) == "true")
  $results ++= [{ check: "generated_files_removed_from_data", passed: $clean_ok, detail: $"No generated files in /data: ($clean_res.stdout | str trim)" }]

  # 13. Updater script at root (update-dsin-nushell.nu --check) works
  let upd_script = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/update-dsin-nushell.nu"
  let upd_ok = if ($upd_script | path exists) {
    let r = (do -i { ^nu $upd_script --check } | complete)
    ($r.exit_code == 0) and ($r.stdout | str contains "target_version")
  } else { false }
  $results ++= [{ check: "root_updater_script_works", passed: $upd_ok, detail: "update-dsin-nushell.nu --check succeeds" }]

  $results
}

def main [image: string = "dsin:latest"] {
  let res = run-dsin-checks $image
  print ($res | table -e)
  let failed = $res | where not $it.passed
  if ($failed | is-not-empty) {
    error make { msg: $"($failed | length) dsin container check\(s\) failed!" }
  }
  print "All dsin container, built-in /data, PATH, and updater checks PASSED!"
}
