# frozen_string_literal: true

module BlueDoc
  module Export
    class Archive < Base
      def perform
        zip_filename = File.join(tmp_path, "#{SecureRandom.uuid}.zip")

        # SUMMARY.md
        summary = BlueDoc::Toc.parse(repository.toc_text).to_markdown(prefix: "./", suffix: ".md")
        write_file!("SUMMARY.md", summary)

        repository.docs.each do |doc|
          body = "# #{doc.title}\n\n#{doc.body_plain}"
          body_html = doc.body_html

          body = downlod_images(body, body_html)
          write_file!("#{doc.slug}.md", body)
        end

        execute("cd #{repo_dir} && zip -r #{zip_filename} ./* && cd -")

        repository.update_export!(:archive, File.open(zip_filename))
      ensure
        FileUtils.rm_rf(self.repo_dir)
        FileUtils.rm_rf(zip_filename) if defined? zip_filename
      end

      # Download images in body into ../images/
      def downlod_images(body, body_html)
        images_dir = File.join(repo_dir, "images")
        FileUtils.mkdir_p(images_dir)

        doc = Nokogiri::HTML(body_html)

        doc.css("img").each do |node|
          src = node.attr("src")
          next if src.blank?

          # match src is /uploads/{key}
          match = src.match(/\/uploads\/([\w]+)/i)
          next if match.nil?
          file_key = match[1]
          next if file_key.nil?

          # Find blob record for get old filename
          blob = ActiveStorage::Blob.find_by(key: file_key)
          next if blob.blank?

          fname = File.join(images_dir, blob.filename.to_s)
          if File.exists?(fname)
            # if same filename exist, rename into {key}.ext
            ext = File.extname(fname)
            fname = File.join(images_dir, "#{file_key}#{ext}")
          end

          # Streaming download blob file into {fname}
          begin
            File.open(fname, "w")  do |f|
              blob.download { |data| f.write(data.force_encoding("UTF-8")) }
            end
          rescue => e
            logger.error "Download blob: #{blob.key} error: #{e.inspect}"
            next
          end

          # replace old "/uploads/{key}" into new src "./images/{new_filename}"
          new_src = "./images/#{File.basename(fname)}"
          logger.info "------- replace image src ----------"
          logger.info "- #{src}"
          logger.info "+ #{new_src}"
          body = body.gsub(src, new_src)
        end

        body
      end
    end
  end
end
