class Admin::TranslationAssignmentsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'admin'

  def new
    @page_heading = 'New Translation Assignment'

    @assignment = TranslationAssignment.new
    @translation_file = @assignment.translation_files.build
  end

  def create
    @assignment = TranslationAssignment.new(translation_assignment_params.merge(total_seats: params[:translation_files][:file].length * 3))
    if @assignment.save
      params[:translation_files][:file].each do |file|
        @translation_file = @assignment.translation_files.create(file: file, translation_assignment_id: @assignment.id)
      end
      redirect_to admin_translation_assignment_path(@assignment), notice: 'Assignment created successfully'
    else
      flash[:error] = 'There was an error'
      render :new
    end
  end

  def show
    @assignment = TranslationAssignment.find(params[:id])
  end

  def index
    @page_heading = 'All Assignments'
    @assignments = TranslationAssignment.all.order(:status, created_at: :desc)
  end

  def archive
    @assignment = TranslationAssignment.find(params[:translation_assignment_id])
    @assignment.archive if @assignment.archivable?
    redirect_to admin_translation_assignment_path(@assignment), notice: 'Assignment is archived'
  end

  private

  def translation_assignment_params
    params.require(:translation_assignment).permit(:title, :description,
                                                   :from_language, :to_language,
                                                   :domain, translation_file_attributes: [:id, :translation_assignment_id, :file])
  end
end
