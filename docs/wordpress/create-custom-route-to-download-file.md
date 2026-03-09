```php
add_action('query_vars', function(array $vars): array {
    $vars[] = 'udc_download_form';

    return $vars;
});

add_action('init', function(): void {
    add_rewrite_rule('^report/download/?$', 'index.php?udc_download_form=true', 'top');
});

add_action('template_include', function(string $template) {
    $isUdcReportDownloadPage = get_query_var('udc_download_form');

    if ($isUdcReportDownloadPage === 'true') {
        $isUdcFormCompleted = $_COOKIE['udcFormCompleted'] ?? 'false';

        header('Cache-Control: no-store, max-age=0');

        if ($isUdcFormCompleted === 'true') {
            header('X-Sendfile: /var/www/private/udc-form/banks-digital-a-recessionary-relationship-reset-mullenlowe-profero.pdf');
            header('Content-Transfer-Encoding: binary');
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename="banks-digital-a-recessionary-relationship-reset-mullenlowe-profero.pdf"');
        } else {
            global $wp_query;

            $wp_query->set_404();
            status_header(404);
            get_template_part(404);
        }

        exit();
    }

    return $template;
});
```
