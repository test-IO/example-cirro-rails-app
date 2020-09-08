class Admin::TranslationAssignmentsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'admin'

  def new
    @page_heading = 'New Translation Assignment'
    
    @assignment = TranslationAssignment.new(invitation_start_time: 2.hours.from_now, invitation_expiry_time: 24.hours.from_now)
    @translation_file = @assignment.translation_files.build
  end

  def create
    @assignment = TranslationAssignment.new(translation_assignment_params)
    if @assignment.save
      params[:translation_files][:file].each do |file|
        @translation_file = @assignment.translation_files.create(file: file, translation_assignment_id: @assignment.id)
      end
      flash[:success] = 'Success'
      redirect_to translation_assignment_path(@assignment)
    else
      flash[:error] = 'There was an error'
      render :new
    end
  end

  def show
    @assignment = TranslationAssignment.find(params[:id])
  end

  private

  def translation_assignment_params
    params.require(:translation_assignment).permit(:title, :description,
                                                   :from_language, :to_language,
                                                   :domain, :invitation_start_time, :invitation_expiry_time,
                                                    translation_file_attributes: [:id, :translation_assignment_id, :file])
  end
end
