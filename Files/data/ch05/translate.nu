# Módulo de traducción con Google Translate
#
# Uso básico:
#   use translate.nu *
#   "Data science at the command line" | trans
#   trans "Machine learning workflows" --destination "fr"

export def trans [
    text?: string                      # Texto a traducir (o desde el pipeline $in)
    --source (-s): string = "auto"     # Idioma de origen (por defecto auto-detección)
    --destination (-d): string = "es"  # Idioma de destino (por defecto español)
    --api-key (-k): string = ""        # Clave opcional de Google Cloud Translation API
] {
    let input_text = if ($text | is-empty) { $in } else { $text }
    if ($input_text | is-empty) {
        error make -u { msg: "Debe proporcionar un texto para traducir (como argumento o mediante tubería)." }
    }

    if ($api_key | is-not-empty) {
        let url = {
            scheme: "https"
            host: "translation.googleapis.com"
            path: "/language/translate/v2"
            params: {
                key: $api_key
                q: $input_text
                source: (if $source == "auto" { "" } else { $source })
                target: $destination
                format: "text"
            }
        } | url join

        let response = http post $url {}
        $response.data.translations.0.translatedText
    } else {
        let url = {
            scheme: "https"
            host: "translate.googleapis.com"
            path: "/translate_a/single"
            params: {
                client: "gtx"
                sl: $source
                tl: $destination
                dt: "t"
                q: $input_text
            }
        } | url join

        http get $url | get 0.0.0
    }
}
