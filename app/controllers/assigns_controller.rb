class AssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :possible_to_destroy_authentification, only: [:destroy]
  
  def create
    @team = Team.friendly.find(params[:team_id])
    user = email_reliable?(assign_params) ? User.find_or_create_by_email(assign_params) : nil
    if user
      @team.invite_member(user)
      if @team.valid?
        redirect_to team_url(@team), notice: I18n.t('views.messages.assigned')
      else
        flash.now[:notice] = I18n.t('views.messages.failed_to_assign')
        render template: 'teams/show'
        # redirect_to team_url(@team), notice: I18n.t('views.messages.failed_to_assign')
      end
    else
      redirect_to team_url(@team), notice: I18n.t('views.messages.failed_to_assign')
    end
  end

  def destroy
    @user = current_user
    assign = Assign.find(params[:id])
    if assign.user_id == current_user.id
      assign.destroy
      flash.now[:notice] = I18n.t('views.messages.user_page_transition')
      render template: "users/show" and return
    end
    destroy_message = assign_destroy(assign, assign.user)
    redirect_to team_url(params[:team_id]), notice: destroy_message
  end

  private

  def assign_params
    params[:email]
  end

  def assign_destroy(assign, assigned_user)
    if assigned_user == assign.team.owner
      I18n.t('views.messages.cannot_delete_the_leader')
    elsif Assign.where(user_id: assigned_user.id).count == 1
      I18n.t('views.messages.cannot_delete_only_a_member')
    elsif assign.destroy
      set_next_team(assign, assigned_user)
      I18n.t('views.messages.delete_member')
    else
      I18n.t('views.messages.cannot_delete_member_4_some_reason')
    end
  end
  
  def email_reliable?(address)
    address.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end
  
  def set_next_team(assign, assigned_user)
    another_team = Assign.find_by(user_id: assigned_user.id).team
    change_keep_team(assigned_user, another_team) if assigned_user.keep_team_id == assign.team_id
  end

  def possible_to_destroy_authentification
    @team = Team.find_by(name: params[:team_id].to_s)
    assign = Assign.find(params[:id])
    unless (assign.user_id == current_user.id) || (@team.owner_id == current_user.id)
      flash.now[:notice] = I18n.t('views.messages.destroy_notification')
      render template: 'teams/show'
    end
  end

end
