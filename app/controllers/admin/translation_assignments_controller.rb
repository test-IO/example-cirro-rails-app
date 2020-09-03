class Admin::TranslationAssignmentsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'admin'

  def new
    @page_heading = 'New Translation Assignment'
    
    @assignment = TranslationAssignment.new(invitation_start_time: 2.hours.from_now, invitation_expiry_time: 24.hours.from_now)
  end

  def create
    @assignment = TranslationAssignment.new(translation_assignment_params)
    if @assignment.save
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
    params.require(:translation_assignment).permit(:title, :description, :content, :from_language, :to_language, :domain, :invitation_start_time, :invitation_expiry_time)
  end
end
