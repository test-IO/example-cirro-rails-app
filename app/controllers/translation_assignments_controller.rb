class TranslationAssignmentsController < ApplicationController
  before_action :fetch_app_worker

  def show
    @assignment = TranslationAssignment.find(params[:id])
    if !@app_worker['gig-ids'].include?(@assignment.gig_idx)
      flash[:error] = 'You are not authorised to view this assignment'
      redirect_to root_path and return
    end
  end

  def index
    @page_heading = 'My Assignments'
    @assignments = TranslationAssignment.where(gig_idx: @app_worker['gig-ids']).order(:status, created_at: :desc)
  end

  private

  def fetch_app_worker
    @app_worker = CirroClient::AppWorker.find(current_user.uid).first
  end
end
