# frozen_string_literal: true

class ProcessHashtagsService < BaseService

  DEFAULT_TAG = 'メイドインアビス'

  KEYWORDS = [
    { keyword_tag: 'mia_staff', keyword_re: %r{つくし(あきひと|卿|先生)|小島正幸|垪和等|飯野慎也|吉成鋼|黄瀬和哉|高倉武史|kevin penkin|キネマシトラス|竹書房} },
    { keyword_tag: 'mia_cast', keyword_re: %r{富田美憂|伊瀬茉莉也|井澤詩織|しーたむ|坂本真綾|大原さやか|豊崎愛生|喜多村英梨|森川智之|日高里菜|沼倉愛美|田村睦心|塙愛美|村田太志|稲田徹|生天目仁美} },
    { keyword_tag: 'mia_orth', keyword_re: %r{ジルオ|ハボルグ|ナット|シギー|キユイ|ライザ|ラフィー|シェルミ|メナエ|殲滅卿|ミオ} },
    { keyword_tag: 'mia_seekercamp', keyword_re: %r{マルルク|オーゼン|監視基地|シーカーキャンプ|地臥せり|イェルメ|ザポ爺|シムレド|不動卿} },
    { keyword_tag: 'mia_idofront', keyword_re: %r{ボン[ドボ]ルド|グ[エェ]イラ|プルシュカ|さおはぶ|(メイナスト)?イリム|祈手|アンブラハンズ|前線基地|イドフロント|カートリッジ|黎明卿} },
    { keyword_tag: 'mia_rikos_party', keyword_re: %r{リコ|レグ|ナナチ|ミーティ|プルシュカ|メイニャ} },
    { keyword_tag: 'mia_artifacts', keyword_re: %r{遺物|星の羅針盤|太陽玉|無尽槌|ブレイズリーブ|火葬砲|インシネレーター|枢機に還す光|スパラグモス|姫乳房|おっぱい石|呪い[よ避]けの(籠|かご|カゴ)|精神隷属機|ゾアホリック|月に触れる|ファーカレス|暁に至る天蓋|明星へ登る|ギャングウェイ|呪い針|シェイカー|ユアワース|命を響く石|千人楔} },
    { keyword_tag: 'mia_ilblu', keyword_re: %r{イルブル|ハディ|ファプタ|マジカジャ|まああ|精算|(はに|ハニ)ー(すく|スク)} },
    { keyword_tag: 'mia_creature', keyword_re: %r{ベニクチナワ|タマウガチ|ネリタンタン|オニツチバシ|タケグマ|ク[ヲオ]ンガタリ|リュウサザイ|カッショウガシラ} },
    { keyword_tag: 'mia_place', keyword_re: %r{オース|ベルチェロ孤児院|シーカーキャンプ|監視基地|イドフロント|前線基地|[な成慣]れ[果は]て村|目の奥|[一二三四五六七1-7１-７]層|アビスの淵|誘いの森|大断層|巨人の盃|なきがらの海|還らずの都|最果ての渦|奈落の底|船団キャラバン} },
    { keyword_tag: 'mia_nether_gryph', keyword_re: %r(奈落文字|ネザーグリフ|悠遠の文字|ビヨンドグリフ|:nrk[0-9a-f]{4}:) },
    { keyword_re: %r{アビス|竹書房|キネマシトラス|上昇負荷|呪い|[電伝]報船|力場|[な成慣]れ[果は]て|不屈の花|トコシエコウ|お祈り骸骨|鈴付き|[赤青蒼月黒白]笛|探窟家|度し難い|奈落シチュー|ラストダイブ|絶界行|奈落} }
  ]

  CONSIDERATION_RE = %r{【考察】}
  CONSIDERATION_TAG = 'メイドインアビス考察班'

  def call(status, tags = [])
    tags = Extractor.extract_hashtags(status.text) if status.local?

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    is_keyword = false

    KEYWORDS.each do |kw|
      if status.text =~ kw[:keyword_re] || status.spoiler_text =~ kw[:keyword_re] then
        is_keyword = true
        if kw[:keyword_tag] then
          status.tags << Tag.where(name: kw[:keyword_tag]).first_or_initialize(name: kw[:keyword_tag])
        end
      end
    end

    if is_keyword then
      status.tags << Tag.where(name: DEFAULT_TAG).first_or_initialize(name: DEFAULT_TAG)
    end

    if status.spoiler_text =~ CONSIDERATION_RE then
      status.tags << Tag.where(name: CONSIDERATION_TAG).first_or_initialize(name: CONSIDERATION_TAG)
    end
    status.update(sensitive: true) if tags.include?('nsfw')
  end
end
