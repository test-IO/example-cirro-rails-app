class TranslationResultsController < ApplicationController
  def create
    @translation_file = TranslationFile.find(params[:translation_file_id])
    @translation_result = current_user.translation_results.create(translation_file: @translation_file, started_at: Time.current)
    @translation_file.pick if @translation_result.persisted?
  end

  def update
    file = params[:translation_result][:file].first
    @translation_result = current_user.translation_results.find(params[:id])
    @translation_result.file = file
    @translation_result.submit

    @translation_result.translation_file.submit_for_review if @translation_result.submitted?
  end
end
