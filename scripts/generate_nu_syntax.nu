#!/usr/bin/env nu
# Generate comprehensive Nushell syntax definition XMLs (nu.xml, nushell.xml) and update pandoc theme for Variable colorization.

export def main [
  --from-docker(-d) # Extract commands from the dsin:latest docker image instead of the host Nushell
] {
  let script_dir = $env.FILE_PWD
  let repo_root = if (($script_dir | path basename) == "scripts") {
    $script_dir | path dirname
  } else {
    $script_dir
  }

  print "Extracting Nushell commands for syntax highlighting..."
  let raw_commands = if $from_docker {
    try {
      sudo -n docker run --rm dsin:latest nu -c 'scope commands | select name type | to json'
      | from json
    } catch {
      scope commands | select name type
    }
  } else {
    scope commands | select name type
  }

  let all_cmds = ($raw_commands | get name)
  let keywords = ($raw_commands | where type == keyword | get name | sort)
  let multi_word = ($all_cmds | where ($it =~ " ") | sort -r | each { |it| $it | str replace -a " " "\\s+" })
  let single_word = ($all_cmds | where not ($it =~ " ") | sort | uniq)

  # Subcommands extracted from multi-word commands (e.g. replace, trim, join)
  let subcmds = ($all_cmds | where ($it =~ " ") | each { |it| $it | split row " " | skip 1 } | flatten | sort | uniq)

  # Course CLI tools and common shell commands
  let course_tools = [
    "dsin", "pbc", "ttt", "timg", "vw", "tapkee", "parallel", "Rscript",
    "python3", "sqlite3", "git", "7z", "jq", "l", "lc", "lo", "le"
  ]

  let all_builtins = (
    $single_word
    | append $subcmds
    | append $course_tools
    | sort
    | uniq
    | where not ($it in $keywords)
  )

  let kw_regex = "<RegExpr String=\"\\b(" + ($keywords | str join '|') + ")\\b\" attribute=\"Keyword\" context=\"#stay\"/>"
  let multi_chunks = (
    $multi_word
    | chunks 50
    | each { |c| "<RegExpr String=\"\\b(" + ($c | str join '|') + ")\\b\" attribute=\"BuiltIn\" context=\"#stay\"/>" }
    | str join (char nl)
  )
  let builtin_chunks = (
    $all_builtins
    | chunks 50
    | each { |c| "<RegExpr String=\"\\b(" + ($c | str join '|') + ")\\b\" attribute=\"BuiltIn\" context=\"#stay\"/>" }
    | str join (char nl)
  )

  let types = [
    "string", "int", "float", "bool", "date", "duration", "filesize",
    "range", "table", "record", "list", "block", "closure", "glob",
    "cell-path", "binary", "any"
  ]
  let type_regex = "<RegExpr String=\"\\b(" + ($types | str join '|') + ")\\b\" attribute=\"DataType\" context=\"#stay\"/>"

  let constants = ["true", "false", "null", "nothing", "in", "out", "err"]
  let const_regex = "<RegExpr String=\"\\b(" + ($constants | str join '|') + ")\\b\" attribute=\"Constant\" context=\"#stay\"/>"

  def build_xml [lang_name: string] {
    let header = '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE language>
<language name="' + $lang_name + '" version="1" kateversion="5.0" section="Scripts" extensions="*.nu" mimetype="application/x-nushell">
  <highlighting>
    <contexts>
      <context name="Normal" attribute="Normal Text" lineEndContext="#stay">
        <DetectSpaces/>
        <DetectChar char="#" attribute="Comment" context="Comment"/>
'
    let rules = [
      $kw_regex,
      $type_regex,
      $const_regex,
      $multi_chunks,
      $builtin_chunks
    ] | str join (char nl)

    let footer = '
        <Detect2Chars char="$" char1="&quot;" attribute="String" context="StringInterp"/>
        <DetectChar char="&quot;" attribute="String" context="StringDQ"/>
        <DetectChar char="' + "'" + '" attribute="String" context="StringSQ"/>
        <DetectChar char="`" attribute="String" context="StringBQ"/>
        <RegExpr String="\$([a-zA-Z_][a-zA-Z0-9_-]*(\.[a-zA-Z0-9_-]+)*)" attribute="Variable" context="#stay"/>
        <RegExpr String="--?[a-zA-Z_][a-zA-Z0-9_-]*" attribute="Attribute" context="#stay"/>
        <RegExpr String="0x[0-9a-fA-F_]+" attribute="BaseN" context="#stay"/>
        <RegExpr String="0b[01_]+" attribute="BaseN" context="#stay"/>
        <RegExpr String="0o[0-7_]+" attribute="BaseN" context="#stay"/>
        <Float attribute="Float" context="#stay"/>
        <Int attribute="DecVal" context="#stay"/>
        <AnyChar String="|=+-*/%!&lt;&gt;&amp;^~" attribute="Operator" context="#stay"/>
      </context>
      <context name="Comment" attribute="Comment" lineEndContext="#pop">
        <DetectSpaces/>
      </context>
      <context name="StringDQ" attribute="String" lineEndContext="#stay">
        <DetectChar char="&quot;" attribute="String" context="#pop"/>
        <Detect2Chars char="\" char1="&quot;" attribute="SpecialChar" context="#stay"/>
        <Detect2Chars char="\" char1="\" attribute="SpecialChar" context="#stay"/>
      </context>
      <context name="StringSQ" attribute="String" lineEndContext="#stay">
        <DetectChar char="' + "'" + '" attribute="String" context="#pop"/>
        <Detect2Chars char="\" char1="' + "'" + '" attribute="SpecialChar" context="#stay"/>
      </context>
      <context name="StringBQ" attribute="String" lineEndContext="#stay">
        <DetectChar char="`" attribute="String" context="#pop"/>
      </context>
      <context name="StringInterp" attribute="String" lineEndContext="#stay">
        <DetectChar char="&quot;" attribute="String" context="#pop"/>
        <Detect2Chars char="\" char1="&quot;" attribute="SpecialChar" context="#stay"/>
        <Detect2Chars char="\" char1="\" attribute="SpecialChar" context="#stay"/>
        <Detect2Chars char="\" char1="(" attribute="SpecialChar" context="#stay"/>
        <DetectChar char="(" attribute="Operator" context="InterpExpr"/>
      </context>
      <context name="InterpExpr" attribute="Normal Text" lineEndContext="#stay">
        <DetectChar char=")" attribute="Operator" context="#pop"/>
        <IncludeRules context="Normal"/>
      </context>
    </contexts>
    <itemDatas>
      <itemData name="Normal Text" defStyleNum="dsNormal"/>
      <itemData name="Keyword" defStyleNum="dsKeyword"/>
      <itemData name="BuiltIn" defStyleNum="dsBuiltIn"/>
      <itemData name="Constant" defStyleNum="dsConstant"/>
      <itemData name="DataType" defStyleNum="dsDataType"/>
      <itemData name="DecVal" defStyleNum="dsDecVal"/>
      <itemData name="BaseN" defStyleNum="dsBaseN"/>
      <itemData name="Float" defStyleNum="dsFloat"/>
      <itemData name="String" defStyleNum="dsString"/>
      <itemData name="Comment" defStyleNum="dsComment"/>
      <itemData name="Operator" defStyleNum="dsOperator"/>
      <itemData name="Variable" defStyleNum="dsVariable"/>
      <itemData name="Attribute" defStyleNum="dsAttribute"/>
      <itemData name="SpecialChar" defStyleNum="dsSpecialChar"/>
    </itemDatas>
  </highlighting>
  <general>
    <comments>
      <comment name="singleLine" value="#"/>
    </comments>
  </general>
</language>
'
    [$header, $rules, $footer] | str join (char nl)
  }

  let nu_xml = (build_xml "nu")
  let nushell_xml = (build_xml "nushell")

  # Target directories
  let targets = [
    $"($repo_root)/Files",
    "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtTheCommandLine/Files",
    "/home/kira/.local/share/pandoc/syntax-definitions",
    "/home/kira/Yandex.Disk/Backups/linux"
  ]

  for target in $targets {
    if ($target | path exists) {
      $nu_xml | save -f ($target | path join "nu.xml")
      $nushell_xml | save -f ($target | path join "nushell.xml")

      # Update theme Variable color if theme exists
      let theme_path = ($target | path join "pandoc_highlight.theme")
      if ($theme_path | path exists) {
        let current_theme = (open $theme_path | from json)
        let updated_theme = ($current_theme | upsert text-styles.Variable.text-color "#e45649")
        $updated_theme | to json -i 4 | save -f $theme_path
      }
      print $"Updated syntax definitions in ($target)"
    }
  }

  print "Syntax XML definitions and theme colorization successfully refreshed."
}
