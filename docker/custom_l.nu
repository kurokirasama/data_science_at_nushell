# =============================================================================
# Custom l and directory listing commands (from host Nushell configuration)
# =============================================================================

# List directory contents sorted by type and name (or by size)
export def l [
  pattern?: glob
  --all(-a)
  --du(-d)
  --sort_by_size(-s)
] {
  let target = ($pattern | default "")
  let res = if ($target | is-empty) {
    if $all and $du {
      ls -a --du
    } else if $all {
      ls -a
    } else if $du {
      ls --du
    } else {
      ls
    }
  } else {
    if $all and $du {
      ls -a --du $pattern
    } else if $all {
      ls -a $pattern
    } else if $du {
      ls --du $pattern
    } else {
      ls $pattern
    }
  }

  if ($res | is-empty) {
    return $res
  }

  if ($du and $sort_by_size) {
    $res | sort-by -i type name | sort-by size
  } else if $sort_by_size {
    $res | sort-by size
  } else {
    $res | sort-by -i type name
  }
}

# List directory contents formatted as a compact grid
export def lc [] {
  l | grid -ci name
}

# List only file names sorted by type and name
export def lo [] {
  ls | sort-by -i type name | reject type size modified
}

# List directory contents sorted by extension
export def le [] {
  ls
  | sort-by -i type name
  | insert "ext" {|item|
      $item.name
      | path parse
      | get extension
    }
  | sort-by ext
}
