module ApplicationHelper
  def avatar_url_for(user, opts = {})
    size = opts[:size] || 48
    hash = Digest::MD5.hexdigest(user.email.downcase)
    "https://secure.gravatar.com/avatar/#{hash}.png?height=#{size}&width=#{size}"
  end

  def domains_collection
    [['Politics', 'politics'], ['Economics', 'economics'], ['Engineering', 'engineering'], ['Media & Entertainment', 'media']]
  end

  def languages_collection
    [['English', 'english'], ['German', 'german'], ['Russian', 'russian'], ['French', 'french'], ['Arabic', 'arabic']]
  end

  def human_readable_translation_file_status(status)
    case status
    when 'available'
      'Ready to pick'
    when 'in_progress'
      'In progress'
    when 'waiting_for_review'
      'Waiting for Review'
    end
  end
end
