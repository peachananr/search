module Locomotive
  class SearchIndexContentEntryJob < BaseSearchJob

    def perform(entry_id, locale)
      ::Mongoid::Fields::I18n.with_locale(locale) do
        entry = Locomotive::ContentEntry.find(entry_id)
        if entry.site == "5adf778b6eabcc00190b75b1" #dev"5ae3ea9872822817a85b0d64"
          index_blog_post(entry.site, entry, locale)
        else
          index_content_entry(entry.site, entry, locale)
        end
      end
    end

  end
end
