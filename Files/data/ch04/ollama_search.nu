# Módulo de búsqueda web estructurada mediante Ollama Search API
#
# Uso básico:
#   use ollama_search.nu *
#   ollama-search "nushell data science pipelines" -n 3
#   ollama-search "command line data science" --md

export def ollama-search [
    query: string                      # Consulta de búsqueda web
    --max-results (-n): int = 5        # Cantidad máxima de resultados a devolver
    --api-key (-k): string = ""        # Token de autenticación de Ollama
    --md (-m)                          # Formatear la salida como texto Markdown
    --verbose (-v)                     # Mostrar mensajes informativos
] {
    let token = if ($api_key | is-not-empty) {
        $api_key
    } else {
        try { $env.OLLAMA_API_KEY } catch { "" }
    }

    if ($token | is-empty) {
        error make -u { msg: "Se requiere un token de Ollama. Use --api-key (-k) o defina $env.OLLAMA_API_KEY." }
    }

    let url = "https://ollama.com/api/web_search"
    let body = { query: $query, max_results: $max_results }
    let headers = {
        Authorization: $"Bearer ($token)"
        "Content-Type": "application/json"
    }

    if $verbose { print $"Consultando la web mediante Ollama Search API: ($query)" }

    let response = try {
        http post -t application/json $url -H $headers $body -e
    } catch { |e|
        error make -u { msg: $"Error de conexión con Ollama Search API: ($e.msg)" }
    }

    let data = if ($response | describe) == "string" {
        $response | from json
    } else {
        $response
    }

    if ($data | get -o error | is-not-empty) {
        error make -u { msg: $"Ollama API Error: ($data.error)" }
    }

    if $md {
        mut md_output = ""
        for item in ($data.results | default []) {
            $md_output = $md_output + $"# ($item.title)\nlink: ($item.url)\n\n($item.content)\n\n"
        }
        return $md_output
    }

    $data.results | default []
}
