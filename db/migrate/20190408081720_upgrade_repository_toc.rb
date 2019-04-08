class UpgradeRepositoryToc < ActiveRecord::Migration[6.0]
  def up
    puts "Upgrading the Old YAML style toc to repository_tocs"
    Repository.all.each do |repo|
      puts "    repo: #{repo.id}"
      RepositoryToc.create_by_toc_text!(repo)
    end
  end
end
