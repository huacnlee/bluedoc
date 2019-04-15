class UpgradeToc < ActiveRecord::Migration[6.0]
  def up
    puts "Upgrading the Old YAML style toc to tocs"
    Repository.all.each do |repo|
      puts "    repo: #{repo.id}"
      begin
        if repo.tocs.blank?
          Toc.create_by_toc_text!(repo)
        end
      rescue => e
        puts "    repo: #{repo.id} upgrade failed: #{e.inspect}"
      end
    end
  end
end
