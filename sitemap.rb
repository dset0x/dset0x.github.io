require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://dset0x.github.io'
SitemapGenerator::Sitemap.create do
  Content.find_each do |content|
    add content_path(content), :lastmod => content.updated_at
  end
end
#SitemapGenerator::Sitemap.ping_search_engines # Not needed if you use the rake tasks
