module Locomotive
  class SearchIndexSiteJob < BaseSearchJob

    def perform(site_id)
      site = Locomotive::Site.find(site_id)

      # first remove all the indices for this site
      search_backend(site, nil)&.clear_all_indices
      ## CUSTOM Index Job for BucketListly Blog Only
      if site_id == "5adf778b6eabcc00190b75b1"
        site.content_types.each do |content_type|
          if content_type.slug == "posts" or content_type.slug == "videos" or content_type.slug == "destinations"
            content_type.entries.visible.each do |entry|
              index_bucketlistly_post(site, entry, locale)
            end
          end
        end
      elsif site_id == "639b26afb83a540004858288"
        site.content_types.each do |content_type|
          if content_type.slug == "posts"
            content_type.entries.visible.each do |entry|
              index_mintsmeals_post(site, entry, locale)
            end
          end
        end
      end

      #else
      #  # index the content in each locale
      #  site.each_locale do |locale|
      #    # index all the pages (except the 404 one and the templatized ones)
      #    site.pages.published.each do |page|
      #      next if page.not_found? || page.templatized? || page.redirect?
      #      index_page(site, page, locale)
      #    end
      #    # index all the content entries
      #    site.content_types.each do |content_type|
      #      content_type.entries.visible.each do |entry|
      #        index_content_entry(site, entry, locale)
      #      end
      #    end
      #  end
      #end
    end

  end
end
