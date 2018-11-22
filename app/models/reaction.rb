class Reaction < ApplicationRecord
  belongs_to :subject, polymorphic: true, required: false
  belongs_to :user, required: false

  attr_accessor :group_count

  def self.create_reaction(name, subject, user: nil)
    user ||= Current.user
    Reaction.find_or_create_by!(subject: subject, name: name.strip, user: user)
  rescue ActiveRecord::RecordNotUnique
    Reaction.where(subject: subject, name: name.strip, user: user).first
  end

  def self.grouped
    items = group(:name).select(:name).count

    results = []
    items.each_key do |name|
      results << Reaction.new(name: name, group_count: items[name])
    end
    results
  end

  def url
    @url ||= "/twemoji/svg/#{Twemoji.find_by_text(text)}.svg"
  end

  def unicode
    @unicode ||= Twemoji.render_unicode(text)
  end

  def text
    @emoji_text ||= ":#{self.name}:"
  end
end
