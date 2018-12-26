# frozen_string_literal: true

module BookLab
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
        doc_files = Dir.glob(File.join(self.repo_dir, "**", "*.{md, markdown}"))
        logger.info "Found #{doc_files.length} docs"

        slug_maps = {}

        doc_files.each do |f|
          original_slug = f.gsub(self.repo_dir + "/", "").split(".").first
          slug = original_slug.gsub("/", "-").downcase

          next if slug == "summary"

          if !BookLab::Slug.valid?(slug)
            slug = Digest::MD5.hexdigest(slug)[0..8]
          end

          slug_maps[original_slug] = slug

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

        # update Toc
        summary_filename = nil
        Dir.glob(File.join(self.repo_dir, "{SUMMARY, summary}.{md, markdown}")) do |f|
          summary_filename = f
        end

        if summary_filename
          toc = File.open(summary_filename).read
          toc.gsub!(/#([\s]?)Summary([\n]?)/, "")
          # ](./hello-world) -> ](hello-world)
          toc.gsub!(/\]\(\.\//, "](")

          slug_maps.each_key do |original_slug|
            slug = slug_maps[original_slug]
            toc.gsub!("#{original_slug}.md", slug)
            toc.gsub!("#{original_slug}.markdown", slug)
            toc.gsub!("#{original_slug}", slug)
          end

          toc_content = ::BookLab::Toc.parse(toc, format: :markdown)
          if repository.update(toc: toc_content.to_yaml)
            logger.warn "Update Repository toc failed, #{repository.errors.inspect}"
          end
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

      # Upload images to BookLab storage and replace body url
      def upload_images(filepath, body)
        html = BookLab::HTML.render(body, format: :markdown)
        doc = Nokogiri::HTML(html)
        filedir = File.dirname(filepath)
        doc.css("img").each do |node|
          src = node.attr("src")
          next if src.blank?

          src_path = src
          unless BookLab::Validate.url?(src_path)
            src_path = File.join(filedir, src)
          end

          begin
            url = BookLab::Blob.upload(src_path)

            body = body.gsub(src, url)
          rescue BookLab::Blob::FileNotFoundError => e
            logger.warn "upload_attachments error: #{e}"
          end
        end

        body
      end
    end
  end
end
