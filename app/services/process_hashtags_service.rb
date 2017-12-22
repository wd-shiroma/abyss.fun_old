# frozen_string_literal: true

class ProcessHashtagsService < BaseService

  CONSIDERATION_RE = %r{【考察】}
  CONSIDERATION_TAG = 'メイドインアビス考察班'

  def call(status, tags = [])
    tags = Extractor.extract_hashtags(status.text) if status.local?

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    if status.spoiler_text =~ CONSIDERATION_RE then
      status.tags << Tag.where(name: CONSIDERATION_TAG).first_or_initialize(name: CONSIDERATION_TAG)
    end
    status.update(sensitive: true) if tags.include?('nsfw')
  end
end
