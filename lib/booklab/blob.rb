module BookLab
  class Blob
    class << self
      IMAGE_SIZES = { tiny: 36, small: 64, medium: 96, large: 440, xlarge: 1600 }

      def service_name
        ActiveStorage::Blob.service.send(:service_name)
      end

      def variation(style)
        ActiveStorage::Variation.new(combine_options: combine_options(style))
      end

      def process_for_aliyun(style)
        style = style&.to_sym
        size = IMAGE_SIZES[style] || IMAGE_SIZES[:small]

        if style == :xlarge
          return "image/resize,w_#{size}"
        else
          return "image/resize,m_fill,w_#{size},h_#{size}"
        end
      end

      def combine_options(style)
        style = style&.to_sym
        size = IMAGE_SIZES[style] || IMAGE_SIZES[:small]

        if style == :xlarge
          { resize: "#{size}>" }
        else
          { thumbnail: "#{size}x#{size}^", gravity: "center", extent: "#{size}x#{size}" }
        end
      end

      def path_for(key)
        ActiveStorage::Blob.service.send(:path_for, key)
      end
    end
  end
end
