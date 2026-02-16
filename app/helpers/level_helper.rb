# frozen_string_literal: true

module LevelHelper
  # レベルに応じたイラストのCloudinary URLを返す
  # @param level [Integer] ユーザーのレベル
  # @return [String] Cloudinary の画像URL
  def level_image_url(level)
    image_data = find_level_image_data(level)
    return default_image_url if image_data.nil?

    Cloudinary::Utils.cloudinary_url(
      image_data["cloudinary_public_id"],
      width: 256,
      height: 256,
      crop: :fill,
      quality: :auto,
      fetch_format: :auto
    )
  end

  # レベルに応じた名前（「芽生え」「日々」など）を返す
  # @param level [Integer] ユーザーのレベル
  # @return [String] レベル名
  def level_name(level)
    image_data = find_level_image_data(level)
    image_data&.dig("name") || "芽生え"
  end

  private

  # レベルに対応する設定データを取得
  def find_level_image_data(level)
    level_images_config["level_images"].find do |image|
      min = image["min"]
      max = image["max"]

      if max.nil?
        level >= min
      else
        level >= min && level <= max
      end
    end
  end

  # YAML設定ファイルを読み込み
  def level_images_config
    @level_images_config ||= YAML.load_file(
      Rails.root.join("config", "level_images.yml")
    )
  end

  # デフォルト画像URL（イラストが見つからない場合のフォールバック）
  def default_image_url
    Cloudinary::Utils.cloudinary_url(
      "beginner",
      width: 256,
      height: 256,
      crop: :fill,
      quality: :auto,
      fetch_format: :auto
    )
  end
end
