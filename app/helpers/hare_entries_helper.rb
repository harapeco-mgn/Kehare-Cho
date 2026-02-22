module HareEntriesHelper
  # ActiveStorage添付ファイルからCloudinary直接URLを生成する
  # ActiveStorageのリダイレクトモードを回避し、Railsサーバーへのリクエストを排除する
  # @param attachment [ActiveStorage::Attached::One] 添付ファイル
  # @param resize_to_limit [Array<Integer>, nil] [width, height] でリサイズ上限を指定
  # @return [String, nil] Cloudinary URL または通常のActiveStorage URL
  def cloudinary_photo_url(attachment, resize_to_limit: nil)
    return nil unless attachment&.attached?

    if Rails.application.config.active_storage.service == :cloudinary
      # 本番環境: storage.yml の folder: <%= Rails.env %> に合わせた public_id
      public_id = "#{Rails.env}/#{attachment.blob.key}"

      options = { quality: :auto, fetch_format: :auto }

      if resize_to_limit
        options[:width] = resize_to_limit[0]
        options[:height] = resize_to_limit[1]
        options[:crop] = :limit
      end

      Cloudinary::Utils.cloudinary_url(public_id, options)
    else
      # 開発・テスト環境: 通常のActiveStorage URLにフォールバック
      url_for(attachment)
    end
  end
end
