module Locomotive
  class SearchIndexSiteJob < BaseSearchJob

    def perform(site_id)
      site = Locomotive::Site.find(site_id)

      # first remove all the indices for this site
      search_backend(site, nil)&.clear_all_indices
      ## CUSTOM Index Job for BucketListly Blog Only
      #if site_id == "5adf778b6eabcc00190b75b1" #dev"5ae3ea9872822817a85b0d64"
      site.content_types.each do |content_type|
        if content_type == "5adf77af6eabcc00190b75b6" or content_type == "5ae2fcb93e788b000b95ee64" or content_type == "5afe6305a6c15b186b7d1943"
        content_type.entries.visible.each do |entry|
          index_important_post(site, entry, locale)
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
