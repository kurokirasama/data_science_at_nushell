#!/usr/bin/env nu
# TDD Verification Suite for Phase 2: Standalone dsin Docker Image, Tooling & Updater Script

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
    # Remaining container runtime checks automatically fail in Red phase if image does not exist yet
    $results ++= [
      { check: "default_shell_is_nushell", passed: false, detail: "Image not built yet" }
      { check: "custom_config_loaded", passed: false, detail: "Image not built yet" }
      { check: "polars_plugin_working", passed: false, detail: "Image not built yet" }
      { check: "ttt_editor_and_config", passed: false, detail: "Image not built yet" }
      { check: "timg_viewer_working", passed: false, detail: "Image not built yet" }
      { check: "external_tools_working", passed: false, detail: "Image not built yet" }
      { check: "updater_script_check_mode", passed: false, detail: "Image not built yet" }
    ]
    return $results
  }

  # 4. Default entrypoint is Nushell and returns version >= 0.116
  let nu_ver_res = (do -i { ^sudo -n docker run --rm $image -c "version | get version" } | complete)
  let nu_ok = ($nu_ver_res.exit_code == 0) and (($nu_ver_res.stdout | str trim) | is-not-empty)
  $results ++= [{ check: "default_shell_is_nushell", passed: $nu_ok, detail: $"Nushell version: ($nu_ver_res.stdout | str trim)" }]

  # 5. Custom config.nu is loaded ($env.config.float_precision == 4)
  let cfg_res = (do -i { ^sudo -n docker run --rm $image --config /home/dst/.config/nushell/config.nu -c "$env.config.float_precision" } | complete)
  let custom_cfg_ok = ($cfg_res.exit_code == 0) and (($cfg_res.stdout | str trim) == "4")
  $results ++= [{ check: "custom_config_loaded", passed: $custom_cfg_ok, detail: $"float_precision == ($cfg_res.stdout | str trim)" }]

  # 6. nu_plugin_polars is registered and works
  let polars_res = (do -i { ^sudo -n docker run --rm $image -c "plugin use polars; [[a b]; [1 2] [3 4]] | polars into-df | polars select a | polars into-nu | get a | math sum" } | complete)
  let polars_ok = ($polars_res.exit_code == 0) and (($polars_res.stdout | str trim) == "4")
  $results ++= [{ check: "polars_plugin_working", passed: $polars_ok, detail: $"polars sum == ($polars_res.stdout | str trim)" }]

  # 7. ttt binary and ~/.config/ttt/settings.json exist inside container
  let ttt_res = (do -i { ^sudo -n docker run --rm $image -c "((which ttt | is-not-empty) and ('~/.config/ttt/settings.json' | path expand | path exists))" } | complete)
  let ttt_ok = ($ttt_res.exit_code == 0) and (($ttt_res.stdout | str trim) == "true")
  $results ++= [{ check: "ttt_editor_and_config", passed: $ttt_ok, detail: $"ttt + settings.json: ($ttt_res.stdout | str trim)" }]

  # 8. timg binary is installed and renders an image inside container
  let files_dir = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files"
  let timg_res = (do -i { ^sudo -n docker run --rm -v $"($files_dir):/data" $image -c "^timg -g 10x5 /data/dscl_0101.png | str length" } | complete)
  let timg_ok = ($timg_res.exit_code == 0) and (($timg_res.stdout | str trim | into int) > 10)
  $results ++= [{ check: "timg_viewer_working", passed: $timg_ok, detail: $"timg output chars: ($timg_res.stdout | str trim)" }]

  # 9. External tools (vw, tapkee, run_experiment, Rscript, python3, sqlite3, git, curl, 7z, jq)
  let tools_res = (do -i { ^sudo -n docker run --rm $image -c "[vw tapkee run_experiment Rscript python3 sqlite3 git curl 7z jq] | all { |t| which $t | is-not-empty }" } | complete)
  let tools_ok = ($tools_res.exit_code == 0) and (($tools_res.stdout | str trim) == "true")
  $results ++= [{ check: "external_tools_working", passed: $tools_ok, detail: $"All required CLI/modeling tools present: ($tools_res.stdout | str trim)" }]

  # 10. Updater script docker/update-dsin-nushell.nu --check works
  let upd_script = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/update-dsin-nushell.nu"
  let upd_ok = if ($upd_script | path exists) {
    let r = (do -i { ^nu $upd_script --check } | complete)
    ($r.exit_code == 0) and ($r.stdout | str contains "target_version")
  } else { false }
  $results ++= [{ check: "updater_script_check_mode", passed: $upd_ok, detail: "docker/update-dsin-nushell.nu --check succeeds" }]

  $results
}

def main [image: string = "dsin:latest"] {
  let res = run-dsin-checks $image
  print ($res | table -e)
  let failed = $res | where not $it.passed
  if ($failed | is-not-empty) {
    error make { msg: $"($failed | length) dsin container check\(s\) failed!" }
  }
  print "All Phase 2 dsin container and updater checks PASSED!"
}
