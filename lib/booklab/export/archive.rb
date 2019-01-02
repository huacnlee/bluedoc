# frozen_string_literal: true

module BookLab
  module Export
    class Archive < Base
      def perform
        zip_filename = File.join(tmp_path, "#{SecureRandom.uuid}.zip")

        # SUMMARY.md
        summary = BookLab::Toc.parse(repository.toc_text).to_markdown(prefix: "./docs/", suffix: ".md")
        write_file!("SUMMARY.md", summary)

        repository.docs.each do |doc|
          body = "# #{doc.title}\n\n#{doc.body_plain}"
          body = public_attachment(body)
          write_file!("docs/#{doc.slug}.md", body)
        end

        execute("cd #{repo_dir} && zip -r #{zip_filename} ./* && cd -")

        repository.update_export!(:archive, File.open(zip_filename))
      ensure
        FileUtils.rm_rf(self.repo_dir)
        FileUtils.rm_rf(zip_filename) if defined? zip_filename
      end

      def public_attachment(body)
        body.gsub("](/uploads/", "](#{Setting.host}/uploads/")
      end
    end
  end
end
