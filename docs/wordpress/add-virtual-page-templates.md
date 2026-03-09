```php
<?php
namespace BFZambiaPayPalDonations;

/**
 * This class injects templates from plugin directory to WordPress admin page.
 *
 * Based on:
 * @link https://www.wpexplorer.com/wordpress-page-templates-plugin/
 */
class PageTemplater
{
    /** @var PageTemplater Reference to an instance of this class. */
    private static $instance;

    /** @var array Reference to an instance of this class. */
    protected $templates;

    private function __construct()
    {
        $this->templates = [];

        // Add a filter to the attributes metabox to inject template into the cache.
        if (version_compare(floatval(get_bloginfo('version')), '4.7', '<')) {
            add_filter('page_attributes_dropdown_pages_args', [$this, 'registerProjectTemplates']);
        } else {
            add_filter('theme_page_templates', [$this, 'addNewTemplate']);
        }

        // Add a filter to the save post to inject out template into the page cache
        add_filter('wp_insert_post_data', [$this, 'registerProjectTemplates']);

        // Add a filter to the template include to determine if the page has our template assigned and return it's path
        add_filter('template_include', [$this, 'viewProjectTemplate']);

        // Add your templates to this array.
        $this->templates = [
            '../page-paypal.php' => 'PayPal',
        ];
    }

    /**
     * Returns an instance of this class.
     *
     * @return PageTemplater
     */
    public static function getInstance(): PageTemplater
    {
        if (null === self::$instance) {
            self::$instance = new PageTemplater();
        }

        return self::$instance;
    }

    /**
     * Adds our template to the page dropdown for v4.7+
     *
     * @param array $postsTemplates New templates to add.
     *
     * @return array
     */
    public function addNewTemplate(array $postsTemplates): array
    {
        $postsTemplates = array_merge($postsTemplates, $this->templates);

        return $postsTemplates;
    }

    /**
     * Adds our template to the pages cache in order to trick WordPress
     * into thinking the template file exists where it doens't really exist.
     */
    public function registerProjectTemplates($atts)
    {
        // Create the key used for the themes cache
        $cache_key = 'page_templates-' . md5(get_theme_root() . '/' . get_stylesheet());

        // Retrieve the cache list. If it doesn't exist, or it's empty prepare an array.
        $templates = wp_get_theme()->get_page_templates();
        if (empty($templates)) {
            $templates = [];
        }

        // New cache, therefore remove the old one
        wp_cache_delete($cache_key, 'themes');

        // Now add our template to the list of templates by merging our templates
        // with the existing templates array from the cache.
        $templates = array_merge($templates, $this->templates);

        // Add the modified cache to allow WordPress to pick it up for listing available templates.
        wp_cache_add($cache_key, $templates, 'themes', 1800);

        return $atts;
    }

    /**
     * Checks if the template is assigned to the page
     */
    public function viewProjectTemplate($template)
    {
        global $post;

        // Return template if post is empty
        if (!$post) {
            return $template;
        }

        // Return default template if we don't have a custom one defined
        if (!isset($this->templates[get_post_meta($post->ID, '_wp_page_template', true)])) {
            return $template;
        }

        $file = plugin_dir_path(__FILE__) . get_post_meta($post->ID, '_wp_page_template', true);

        // Just to be safe, we check if the file exist first
        if (file_exists($file)) {
            return $file;
        } else {
            echo $file;
        }

        return $template;
    }
}

add_action('plugins_loaded', ['BFZambiaPayPalDonations\PageTemplater', 'getInstance']);
```
