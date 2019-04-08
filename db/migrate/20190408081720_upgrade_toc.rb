class UpgradeToc < ActiveRecord::Migration[6.0]
  def up
    puts "Upgrading the Old YAML style toc to tocs"
    Repository.all.each do |repo|
      puts "    repo: #{repo.id}"
      Toc.create_by_toc_text!(repo)
    end
  end
end
