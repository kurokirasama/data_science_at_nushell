# Módulo de utilidades estadísticas para Ciencia de Datos en Nushell

export def resumen-columna [col: string]: table -> record {
    let vals = ($in | get $col)
    {
        columna: $col
        n: ($vals | length)
        media: ($vals | math avg | math round --precision 3)
        mediana: ($vals | math median | math round --precision 3)
        desv_est: ($vals | math stddev | math round --precision 3)
        minimo: ($vals | math min)
        maximo: ($vals | math max)
    }
}

export def filtrar-outliers [col: string, --z-max: float = 2.5]: table -> table {
    let tbl = $in
    let mu = ($tbl | get $col | math avg)
    let sd = ($tbl | get $col | math stddev)
    $tbl | where { |row| ((($row | get $col) - $mu) | math abs) <= ($z_max * $sd) }
}
