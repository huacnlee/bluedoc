# frozen_string_literal: true

module BookLab
  module Import
    class GitBook
      delegate :logger, to: Rails

      attr_accessor :repository, :user, :git_url

      # git_url: Git Url of GitBook source
      # repository: Import destination of Repository
      # user: importer user
      def initialize(repository:, user:, git_url:)
        @user = user
        @repository = repository
        @git_url = git_url
      end

      def perform
        tmp_path = Rails.root.join("tmp", "import", "gitbook")
        dirname = Digest::MD5.hexdigest(self.git_url)

        FileUtils.mkdir_p(tmp_path)
        `git clone --depth 1 #{self.git_url} #{tmp_path}/#{dirname}`

        repo_dir = File.join(tmp_path, dirname)

        # import docs
        doc_files = Dir.glob(File.join(repo_dir, "**", "*.{md, markdown}"))
        logger.info "Found #{doc_files.length} docs"

        slug_maps = {}

        doc_files.each do |f|
          original_slug = f.gsub(repo_dir + "/", "").split(".").first
          slug = original_slug.gsub("/", "-").downcase

          next if slug == "summary"

          if !BookLab::Slug.valid?(slug)
            slug = Digest::MD5.hexdigest(slug)[0..8]
          end

          slug_maps[original_slug] = slug

          body = File.open(f).read

          doc_params = {
            title: self.parse_title(body),
            slug: slug,
            repository_id: repository.id,
            creator_id: user.id,
            body: body
          }

          doc = self.repository.docs.find_by_slug(slug)

          begin
            if doc.blank?
              doc = Doc.create!(doc_params)
            else
              doc_params.delete(:slug)
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
        Dir.glob(File.join(repo_dir, "{SUMMARY, summary}.{md, markdown}")) do |f|
          summary_filename = f
        end

        if summary_filename
          toc = File.open(summary_filename).read
          toc.gsub!(/#([\s]?)Summary([\n]?)/, "")

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
        FileUtils.rm_rf(File.join(tmp_path, dirname))
      end

      def parse_title(body)
        lines = body.split("\n")

        first_line = lines[0] || ""
        if first_line.start_with? "#"
          body.gsub!(first_line, "")
          return first_line.gsub(/#[\s]?/, "")
        end

        first_line
      end
    end
  end
end
