class UpgradeToc < ActiveRecord::Migration[6.0]
  def up
    puts "Upgrading the Old YAML style toc to tocs"
    Repository.all.each do |repo|
      next if repo.tocs.any?

      puts "    repo: #{repo.id}"
      begin
        Toc.create_by_toc_text!(repo)
      rescue
        puts "    repo: #{repo.id} upgrade failed"
      end
    end
  end
end
