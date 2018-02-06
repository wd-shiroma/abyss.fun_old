# frozen_string_literal: true

namespace :default_hashtag do
  desc 'Add default hashtag to untagged public statuses'
  task migrate: :environment do
    tag = Tag.where(name: ENV['DEFAULT_HASHTAG']).first_or_initialize(name: ENV['DEFAULT_HASHTAG'])

    if tag.save then
      Status.includes(:tags).where(local: true, visibility: :public).find_each do |status|
        next if status.tags.any? {|t| t.name === ENV['DEFAULT_HASHTAG']}
        status.tags << tag
        status.save
      end
    end
  end
end
