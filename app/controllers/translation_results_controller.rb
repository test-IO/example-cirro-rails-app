class TranslationResultsController < ApplicationController
  before_action :authenticate_user!

  def create
    @translation_file = TranslationFile.find(params[:translation_file_id])

    if other_started_translation_file_exists?
      @translation_file.errors.add(:base, 'Please complete your ongoing work before starting another one!')
    else
      @translation_result = current_user.translation_results.create(translation_file: @translation_file, started_at: Time.current)
      @translation_file.pick if @translation_result.persisted?
    end
  end

  def update
    file = params[:translation_result][:file].first
    @translation_result = current_user.translation_results.find(params[:id])
    @translation_result.file = file
    @translation_result.submit

    @translation_file = @translation_result.translation_file
    if @translation_result.submitted?
      @translation_file.submit_for_review
    else
      @translation_file.errors.add(:base, @translation_result.errors.full_messages.to_sentence)
    end
  end

  private

  def other_started_translation_file_exists?
    translation_file_ids = TranslationFile.where(translation_assignment_id: @translation_file.translation_assignment_id).pluck(:id)
    current_user.translation_results.started.where(translation_file_id: translation_file_ids).exists?
  end
end
