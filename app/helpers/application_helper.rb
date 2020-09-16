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

  def human_readable_translation_file_status(translation_file)
    case translation_file.status
    when 'available'
      'Ready to pick'
    when 'in_progress'
      'In progress'
    when 'waiting_for_review'
      'Waiting for Review'
    when 'reviewed'
      translation_file.translation_result.user_id == current_user.id ? translation_file.translation_result.status.capitalize : 'Reviewed'
    when 'expired'
      'Expired'
    end
  end
end
