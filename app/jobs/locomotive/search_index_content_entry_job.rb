module Locomotive
  class SearchIndexContentEntryJob < BaseSearchJob

    def perform(entry_id, locale)
      ::Mongoid::Fields::I18n.with_locale(locale) do
        entry = Locomotive::ContentEntry.find(entry_id)
        puts "#{entry.site} xxxxxxxx"
        if entry.site == "5adf778b6eabcc00190b75b1"
          if entry._type == "Locomotive::ContentEntry5adf77af6eabcc00190b75b6" or entry._type == "Locomotive::ContentEntry5ae2fcb93e788b000b95ee64" or entry._type == "Locomotive::ContentEntry5afe6305a6c15b186b7d1943"
            index_bucketlistly_post(entry.site, entry, locale)
          end
        elsif entry.site == "639b26afb83a540004858288"
          if entry._type == "Locomotive::ContentEntry639b2d4bb83a54000485828d"
            index_mintsmeals_post(entry.site, entry, locale)
          end
        end
      end
    end

  end
end
