module Locomotive
  class SearchIndexContentEntryJob < BaseSearchJob

    def perform(entry_id, locale)
      ::Mongoid::Fields::I18n.with_locale(locale) do
        entry = Locomotive::ContentEntry.find(entry_id)

        #if entry.site == "5adf778b6eabcc00190b75b1" #dev"5ae3ea9872822817a85b0d64"
        if entry._type == "Locomotive::ContentEntry5adf77af6eabcc00190b75b6" or entry._type == "Locomotive::ContentEntry5ae2fcb93e788b000b95ee64" or entry._type == "Locomotive::ContentEntry5afe6305a6c15b186b7d1943"
          index_important_post(entry.site, entry, locale)
        end




        # Run Clear Cache Rake On Save Using Rake Tasks from Engine
        puts "xxxx #{entry._slug}"

        if entry._type == "Locomotive::ContentEntry5adf77af6eabcc00190b75b6" or entry._type == "Locomotive::ContentEntry5ae2fcb93e788b000b95ee64" or entry._type == "Locomotive::ContentEntry5afe6305a6c15b186b7d1943"
          if entry._type == "Locomotive::ContentEntry5adf77af6eabcc00190b75b6"
            url = "/posts/#{entry._slug}"
          end
          if entry._type == "Locomotive::ContentEntry5ae2fcb93e788b000b95ee64"
            url = "/destinations/#{entry._slug}"
          end
          if entry._type == "Locomotive::ContentEntry5afe6305a6c15b186b7d1943"
            url = "/videos/#{entry._slug}"
          end
          require 'rake'
          Rake::Task["admin:redis_cc"].invoke("#{url}")
        end
        #else
        #  index_content_entry(entry.site, entry, locale)
        #end
      end
    end

  end
end
