class TranslationAssignmentsController < ApplicationController
  before_action :fetch_app_worker

  def show
    @assignment = TranslationAssignment.find(params[:id])
    @gig_invitation =  @app_worker.gig_invitations.find {|gi| gi.gig_id == @assignment.gig_idx }
    if !@gig_invitation || @gig_invitation.status == 'rejected'
      flash[:error] = 'You are not authorised to view this assignment'
      redirect_to root_path and return
    end
  end

  def index
    @type = params[:type] || 'new'
    @page_heading = 'My Assignments'

    if @type == 'new'
      gig_ids =  @app_worker.gig_invitations.select {|gi| gi.status == 'pending' }.map(&:gig_id)
      @assignments = TranslationAssignment.where(gig_idx: gig_ids, status: 'active').order(created_at: :desc)
    elsif @type == 'current'
      gig_ids =  @app_worker.gig_invitations.select {|gi| gi.status == 'accepted' }.map(&:gig_id)
      @assignments = TranslationAssignment.where(gig_idx: gig_ids, status: 'active').order(created_at: :desc)
    else
      gig_ids =  @app_worker.gig_invitations.select {|gi| gi.status == 'accepted' }.map(&:gig_id)
      @assignments = TranslationAssignment.where(gig_idx: gig_ids, status: 'archived').order(created_at: :desc)
    end
  end

  def accept
    @assignment = TranslationAssignment.find(params[:id])
    @gig_invitation =  @app_worker.gig_invitations.find {|gi| gi.gig_id == @assignment.gig_idx }
    redirect_to translation_assignment_path(@assignment), notice: 'Assignment accepted successfully'
  end

  def reject
    @assignment = TranslationAssignment.find(params[:id])
    @gig_invitation =  @app_worker.gig_invitations.find {|gi| gi.gig_id == @assignment.gig_idx }
    redirect_to root_path(@assignment), notice: 'Assignment rejected successfully'
  end

  private

  def fetch_app_worker
    @app_worker = CirroClient::AppWorker.includes(:gig_invitations).find(current_user.uid).first
  end
end
