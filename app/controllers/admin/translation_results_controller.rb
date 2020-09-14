class Admin::TranslationResultsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :fetch_translation_result

  layout 'admin'

  def accept
    @translation_result.accept!
  end

  def reject
    @translation_result.reject!
  end

  private

  def fetch_translation_result
    @translation_result = TranslationResult.find(params[:id])
  end
end
