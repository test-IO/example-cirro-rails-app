class TranslationAssignmentsController < ApplicationController
  before_action :fetch_invitations
  before_action :fetch_assignment, except: [:index]

  def show
    if !@gig_invitation || @gig_invitation.status == 'rejected'
      flash[:error] = 'You are not authorised to view this assignment'
      redirect_to root_path and return
    end
  end

  def index
    @type = params[:type] || 'new'
    @page_heading = 'My Assignments'

    if @type == 'new'
      invitation_status = 'pending'
      status = 'active'
    elsif @type == 'current'
      invitation_status = 'accepted'
      status = 'active'
    else
      invitation_status = 'accepted'
      status = 'archived'
    end

    gig_ids =  @gig_invitations.select {|gi| gi.status == invitation_status }.map(&:gig_id)
    @assignments = TranslationAssignment.where(gig_idx: gig_ids, status: status).order(created_at: :desc)
  end

  def accept
    CIRRO_V2_CLIENT.GigInvitation.accept(@gig_invitation.id)

    redirect_to translation_assignment_path(@assignment), notice: 'Assignment accepted successfully'
  end

  def reject
    CIRRO_V2_CLIENT.GigInvitation.reject(@gig_invitation.id)

    redirect_to root_path(@assignment), notice: 'Assignment rejected successfully'
  end

  private

  def fetch_invitations
    @gig_invitations = CIRRO_V2_CLIENT.GigInvitation.list(user_id: current_user.uid).data
  end

  def fetch_assignment
    @assignment = TranslationAssignment.find(params[:id])
    @gig_invitation = @gig_invitations.find {|gi| gi.gig_id.to_s == @assignment.gig_idx.to_s }
  end
end
