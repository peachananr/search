module Locomotive
  module Concerns
    module ContentEntry

      module IndexContent

        def content_to_index
          self.custom_fields_basic_attributes.map do |(name, value)|
            _name = name.gsub(/_id$/, '').gsub(/_url$/, '')

            next if !value.is_a?(String) ||
              name == _label_field_name.to_s || # no need to index the label (already searchable)
              name.end_with?('_id') || # don't index attributes like youtube_id, ...etc
              value =~ /^(https?:\/)?\/[^\s]+$/ || # don't index the field with only an absolute or relative url
              self.file_custom_fields.include?(_name)

            sanitize_search_content(value)
          end.compact.join(' ').strip
        end

        def data_to_index(parent = false)
          data = default_data_to_index

          data.merge!(self.custom_fields_basic_attributes) unless parent

          # we also index the belongs_to relationships but we only keep
          # the most important data: _label, _slug, _content_type and
          # potentially their own belongs_to relationships (recursive)
          self.belongs_to_custom_fields.each do |name|
            data[name] = send(name.to_sym)&.data_to_index(true)
          end

          data
        end

        ## CUSTOM Index Job for BucketListly Blog Only
        def blog_post_to_index
          require 'nokogiri'
          self.custom_fields_basic_attributes.map do |(name, value)|
            if name == "body"
              html = Nokogiri.HTML(value)
              content = ""

              if html.css("#table-of-contents").size != 0
                html.css("#table-of-contents").first.remove
              end
              if html.css(".readmore-block").size != 0
                html.css(".readmore-block").each do |i|
                  i.remove
                end
              end
              if html.css(".video-block").size != 0
                html.css(".video-block").each do |i|
                  i.remove
                end
              end
              if html.css(".audio-block").size != 0
                html.css(".audio-block").each do |i|
                  i.remove
                end
              end
              if html.css("ul").size != 0
                html.css("ul").each do |i|
                  i.remove
                end
              end
              if html.css(".btn-wrap").size != 0
                html.css(".btn-wrap").each do |i|
                  i.remove
                end
              end

              html.css("h2, h3, h4").each do |i|
                content = "#{content} #{i.text} "
              end

              html.css("p").each_with_index do |i, index|
                if index > 9
                  break
                else
                  content = "#{content} #{i.text} "
                end
              end
              content
              #truncate_desc(sanitize_search_content(content).downcase.chomp.gsub(/[^0-9A-Za-z ]/, ' ').split(" ").uniq.select{|w| w.length >= 3}.join(" "), 8000)

              #text_only = sanitize_search_content(html.inner_html)
              #truncate_desc(text_only.downcase.chomp.gsub(/[^0-9A-Za-z ]/, ' ').split(" ").uniq.select{|w| w.length >= 3}.join(" "), 8000)
            else
              next
            end
          end.compact.join(' ').strip
        end

        def destinations_to_index
          self.custom_fields_basic_attributes.map do |(name, value)|
            if name == "desc"
              sanitize_search_content(value)
            else
              next
            end
          end.compact.join(' ').strip
        end

        def blog_post_data_to_index
          if self.meta_description.nil? or self.meta_description.empty?
            desc = truncate_desc(sanitize_search_content(self.body), 200)
          else
            desc = self.meta_description
          end

          data = {
            '_content_type' => self.content_type.slug,
            '_slug'         => self._slug,
            '_label'        => self._label,
            'subtitle'        => self.subtitle,
            'description'   => desc,
            'thumbnail'     => self.header_img_thumb.url
          }

          data
        end

        def video_data_to_index
          data = {
            '_content_type' => self.content_type.slug,
            '_slug'         => self._slug,
            '_label'        => self._label,
            'description'   => truncate_desc(sanitize_search_content(self.body), 200),
            'thumbnail'     => self.cover_image_thumb.url
          }

          data
        end

        def destination_data_to_index

          data = {
            '_content_type' => self.content_type.slug,
            '_slug'         => self._slug,
            '_label'        => self._label,
            'description'   => truncate_desc(sanitize_search_content(self.desc), 200),
            'thumbnail'     => self.clean_image.url
          }

          data
        end

        private

        def index_content
          # don't index an unpublished entry or entry that is not posts, destinations, and videos
          return if !self.visible? or (self._type != "Locomotive::ContentEntry5adf77af6eabcc00190b75b6" and self._type !=  "Locomotive::ContentEntry5ae2fcb93e788b000b95ee64" and self._type !=  "Locomotive::ContentEntry5afe6305a6c15b186b7d1943")

          Locomotive::SearchIndexContentEntryJob.perform_later(
            self._id.to_s,
            ::Mongoid::Fields::I18n.locale.to_s
          )
        end

        def unindex_content
          Locomotive::SearchDeleteContentEntryIndexJob.perform_later(
            self.site_id.to_s,
            self.content_type.slug,
            self._id.to_s,
            ::Mongoid::Fields::I18n.locale.to_s
          )
        end

        def default_data_to_index
          {
            '_content_type' => self.content_type.slug,
            '_slug'         => self._slug,
            '_label'        => self._label
          }
        end

      end

    end
  end
end
