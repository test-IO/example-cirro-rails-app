module ApplicationHelper
  def avatar_url_for(user, opts = {})
    size = opts[:size] || 48
    hash = Digest::MD5.hexdigest(user.email.downcase)
    "https://secure.gravatar.com/avatar/#{hash}.png?height=#{size}&width=#{size}"
  end

  def domains_collection
    [['politics', 'Politics'], ['economics', 'Economics'], ['engineering', 'Engineering'], ['media', 'Media & Entertainment']]
  end

  def languages_collection
    [['english', 'English'], ['german', 'German'], ['russian', 'Russian'], ['french', 'French'], ['arabic', 'Arabic']]
  end
end
