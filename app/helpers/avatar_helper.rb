module AvatarHelper
  DICEBEAR_BASE_URL = "https://api.dicebear.com/7.x/lorelei/svg"

  # Cottagecore background colors (sage, rose, taupe, lavender, cream)
  BACKGROUNDS = %w[b8c9b8 d4a5a5 c9b8a8 c8bfd4 fdf8f3].freeze

  def avatar_url(user, size: 80)
    seed = user&.email.present? ? Digest::MD5.hexdigest(user.email.strip.downcase) : "default"
    bg = BACKGROUNDS[seed.hex % BACKGROUNDS.length]
    "#{DICEBEAR_BASE_URL}?seed=#{seed}&size=#{size}&backgroundColor=#{bg}"
  end

  def avatar_tag(user, size: 80, html_options: {})
    default_classes = "rounded-full"
    html_options[:class] = [ default_classes, html_options[:class] ].compact.join(" ")
    html_options[:alt] ||= "Avatar"

    image_tag(avatar_url(user, size: size), **html_options)
  end
end
