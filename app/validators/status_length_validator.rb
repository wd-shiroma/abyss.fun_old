# frozen_string_literal: true

class StatusLengthValidator < ActiveModel::Validator
  MAX_CHARS = 500
  NARAKU_PATTERN = %r{:nrk[0-9a-f]{4}:}

  def validate(status)
    return unless status.local? && !status.reblog?
    status.errors.add(:text, I18n.t('statuses.over_character_limit', max: MAX_CHARS)) if too_long?(status)
  end

  private

  def too_long?(status)
    countable_length(status) > MAX_CHARS
  end

  def countable_length(status)
    total_text(status).mb_chars.grapheme_length
  end

  def total_text(status)
    [status.spoiler_text, countable_text(status)].join
  end

  def countable_text(status)
    return '' if status.text.nil?

    status.text.dup.tap do |new_text|
      new_text.gsub!(FetchLinkCardService::URL_PATTERN, 'x' * 23)
      new_text.gsub!(Account::MENTION_RE, '@\2')
      new_text.gsub!(NARAKU_PATTERN, 'xx')
    end
  end
end
