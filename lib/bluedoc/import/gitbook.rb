# frozen_string_literal: true

module BlueDoc
  module Import
    class GitBook < Base
      def git_url
        self.url
      end

      def valid_url?
        self.url&.start_with?("git@") || self.url&.start_with?("http")
      end

      def download
        self.execute("git clone --depth 1 #{self.url} #{self.repo_dir}")
      end

      def perform
        raise "Invalid git url" if !valid_url?

        self.download

        # import docs
        doc_files = Dir.glob(File.join(self.repo_dir, "**", "*.{md, markdown}"), File::FNM_CASEFOLD)
        logger.info "Found #{doc_files.length} docs"

        # update Toc
        summary_filenames = Dir.glob(File.join(self.repo_dir, "**", "summary.{md, markdown}"), File::FNM_CASEFOLD)
        # take first (parent dir first) summary.md
        summary_filename = summary_filenames.first

        slug_maps = {}

        # root dir
        root_dir = self.repo_dir + "/"
        first_file = doc_files.first
        if first_file
          # use first file path as root dir for slug
          root_dir = File.dirname(first_file) + "/"
        end
        if summary_filename
          # use summary.md path as root dir if it exist
          root_dir = File.dirname(summary_filename) + "/"
        end

        doc_files.each do |f|
          fname = f.gsub(root_dir, "")
          # remove self.repo_dir + "/" again, if summary.md in sub dir
          fname = fname.gsub(self.repo_dir + "/", "")

          original_slug = fname.split(".").first
          slug = BlueDoc::Slug.slugize(original_slug).downcase

          next if slug == "summary"

          if !BlueDoc::Slug.valid?(slug)
            slug = Digest::MD5.hexdigest(slug)[0..8]
          end

          slug_maps[fname] = slug

          body = self.upload_images(f, File.open(f).read)
          title_res = self.parse_title(body)

          doc_params = {
            title: title_res[:title],
            slug: slug,
            repository_id: self.repository.id,
            creator_id: self.user&.id,
            body: title_res[:body]
          }

          doc = self.repository.docs.find_by_slug(slug)

          begin
            if doc.blank?
              doc = Doc.create!(doc_params)
            else
              doc_params.delete(:slug)
              doc_params.delete(:creator_id)
              doc.update!(doc_params)
            end
          rescue => e
            logger.warn "doc #{doc_params[:slug]} save error: #{e.message}"
            next
          end

          logger.info "doc:#{doc.id} #{doc.slug} created"
        end

        if summary_filename
          toc = File.open(summary_filename).read
          toc.gsub!(/#([\s]?)Summary([\n]?)/, "")
          # ](./hello-world) -> ](hello-world)
          toc.gsub!(/\]\(\.\//, "](")

          slug_maps.each_key do |fname|
            slug = slug_maps[fname]
            toc.gsub!("](#{fname}", "](#{slug}")
          end

          toc_content = ::BlueDoc::Toc.parse(toc, format: :markdown)
          ::Toc.create_by_toc_text!(self.repository, toc: toc_content.to_yaml)
        end
      ensure
        FileUtils.rm_rf(self.repo_dir)
      end

      def parse_title(body)
        body = body.dup
        lines = body.split("\n")

        first_line = lines[0] || ""
        if first_line.start_with? "#"
          body = body.gsub(first_line, "").strip
          return { title: first_line.gsub(/#[\s]?/, ""), body: body }
        end

        { title: first_line, body: body }
      end

      # Upload images to BlueDoc storage and replace body url
      def upload_images(filepath, body)
        html = BlueDoc::HTML.render(body, format: :markdown)
        doc = Nokogiri::HTML(html)
        filedir = File.dirname(filepath)
        doc.css("img").each do |node|
          src = node.attr("src")
          next if src.blank?

          src_path = src
          unless BlueDoc::Validate.url?(src_path)
            src_path = File.join(filedir, src)
          end

          begin
            url = BlueDoc::Blob.upload(src_path)

            body = body.gsub(src, url)
          rescue BlueDoc::Blob::FileNotFoundError => e
            logger.warn "upload_attachments error: #{e}"
          end
        end

        body
      end
    end
  end
end
