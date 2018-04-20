# frozen_string_literal: true


class ProcessHashtagsService < BaseService

  DEFAULT_TAG = 'メイドインアビス'

  KEYWORDS = [
    {
        keyword_tag: "mia_staff",
        keyword_re: %r{つくし\s*(あきひと|卿|先生)|小島\s*正幸|垪\s*和等|飯野\s*慎也|吉成\s*鋼|黄瀬\s*和哉|高倉\s*武史|kevin\s+penkin|キネマシトラス|竹書房}
    }, {
        keyword_tag: "mia_cast",
        keyword_re: %r{富田\s*美憂|伊瀬\s*茉莉也|井澤\s*詩織|坂本\s*真綾|大原\s*さやか|豊崎\s*愛生|喜多村\s*英梨|森川\s*智之|日高\s*里菜|沼倉\s*愛美|田村\s*睦心|塙\s*愛美|村田\s*太志|稲田\s*徹|生天目\s*仁美},
        keyword_ma: [ 'しーたむ' ]
    }, {
        keyword_tag: "mia_orth",
        keyword_re: %r{殲滅卿},
        keyword_ma: [ 'きゆい', 'しぇるみ', 'しぎー', 'じるお', 'なっと', 'はぼるぐ', 'べるちぇろ', 'みお', 'めなえ', 'らいざ', 'らふぃー' ]
    }, {
        keyword_tag: "mia_seekercamp",
        keyword_re: %r{監視基地|シーカーキャンプ|地臥せり|不動卿},
        keyword_ma: [ 'いぇるめ', 'おーぜん', 'ざぽ', 'しむれど', 'まるるく' ]
    }, {
        keyword_tag: "mia_idofront",
        keyword_re: %r{祈手|アンブラハンズ|前線基地|黎明卿|カートリッジ},
        keyword_ma: [ 'いどふろんと', 'いりむ', 'ぐえいら', 'さおはぶ', 'ぼんどるど', 'めいなすといりむ', 'ぷるしゅか' ]
    }, {
        keyword_tag: "mia_rikos_party",
        keyword_ma: [ 'ななち', 'みーてぃ', 'めいにゃ', 'りこ', 'れぐ', 'ぷるしゅか' ]
    }, {
        keyword_tag: "mia_artifacts",
        keyword_re: %r{暁に至る天蓋|命を響く石|遺物|おっぱい石|火葬砲|枢機に還す光|精神隷属機|千人楔|太陽玉|月に触れる|呪い針|呪い避けの籠|姫乳房|星の羅針盤|明星へ登る|無尽槌},
        keyword_ma: [ 'いんしねれーた', 'ぎゃんぐうぇい', 'しぇいかー', 'すぱらぐもす', 'ぞあほりっく', 'ふぁーかれす', 'ぶれいずりーぶ', 'ゆあわーす' ]
    }, {
        keyword_tag: "mia_ilblu",
        keyword_re: %r{干渉器|先触れの獣|三賢},
        keyword_ma: [ 'いるぶる', 'しょうろう', 'どぶーぐ', 'はでぃ', 'はにーすく', 'ふぁぷた', 'ぶえこ', 'ぶえろえるこ', 'べらふ', 'まああ', 'まじかじゃ', 'わずきゃん' ]
    }, {
        keyword_tag: "mia_creature",
        keyword_re: %r{[慣成な]れ[は果]て},
        keyword_ma: [ 'くおんがたり', 'たけぐま', 'たまうがち', 'ねりたんたん', 'べにくちなわ', 'りゅうさざい' ]
    }, {
        keyword_tag: "mia_place",
        keyword_re: %r{ベルチェロ孤児院|シーカーキャンプ|監視基地|前線基地|[な成慣]れ[果は]て村|目の奥|[一二三四五六七1-7１-７]層|アビスの淵|誘いの森|大断層|巨人の盃|なきがらの海|還らずの都|最果ての渦|奈落の底|船団キャラバン},
        keyword_ma: [ 'おーす', 'いどふろんと', 'どぐーぶ', 'しょうろう' ]
    }, {
        keyword_tag: "mia_nether_gryph",
        keyword_re: %r(奈落文字|悠遠の文字|:nrk[0-9a-f]{4}:),
        keyword_ma: [ 'ねざーぐりふ', 'びよんどぐりふ' ]
    }, {
        keyword_re: %r{竹書房|キネマシトラス|上昇負荷|呪い|[電伝]報船|力場|[な成慣]れ[果は]て|不屈の花|お祈り骸骨|鈴付き|[赤青蒼月黒白]笛|探窟家|度し難|奈落シチュー|ラストダイブ|絶界行},
        keyword_ma: [ 'アビス', 'とこしえこう', 'んなぁ' ]
    },
  ]

  CONSIDERATION_RE = %r{【考察】}
  CONSIDERATION_TAG = 'メイドインアビス考察班'

  def call(status, tags = [])
    require 'jumanpp_ruby'

    tags = Extractor.extract_hashtags(status.text) if status.local?

    is_keyword = false

    if status.local? && !status.reply? then
      jumanpp = JumanppRuby::Juman.new(force_single_path: :true)

      status_words = []
      jumanpp.parse(status.text) do |wd|
        status_words.push(wd[1]) if wd[3] == '名詞' || wd[3] == '感動詞'
      end

      KEYWORDS.each do |kw|
        if kw[:keyword_re] && ( status.text =~ kw[:keyword_re] || status.spoiler_text =~ kw[:keyword_re] ) then
          is_keyword = true
          if kw[:keyword_tag] then
            tags << kw[:keyword_tag]
          end
        end
        if kw[:keyword_ma] then
          status_words.each do |wd|
            if kw[:keyword_ma].include?(wd) then
              is_keyword = true
              if kw[:keyword_tag] then
                tags << kw[:keyword_tag]
              end
            end
          end
        end
      end
    end

    if is_keyword then
      tags << DEFAULT_TAG
    end

    if status.spoiler_text =~ CONSIDERATION_RE then
      tags << CONSIDERATION_TAG
    end

    if Rails.configuration.x.default_hashtag.present? && status.visibility == 'public' && status.local? && !status.reply? then
      tags << Rails.configuration.x.default_hashtag
    end

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    status.update(sensitive: true) if tags.include?('nsfw')
  end
end
