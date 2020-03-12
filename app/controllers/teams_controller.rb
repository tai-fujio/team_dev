class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]
  before_action :possible_to_edit_authentification, only: [:edit]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:notice] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:notice] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def team_owner_delegation
    @team = Team.find(params[:id])
    @team.owner_id = params[:user_id]
    user = User.find(@team.owner_id)
    if @team.save
      OwnerChangeMailer.owner_change_notification(user.email,@team).deliver
      redirect_to @team, notice: I18n.t('views.messages.owner_delegation')
    else
      flash.now[:error] = I18n.t('views.messages.owner_delegation_failed')
      render :show
    end
  end
  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

  def possible_to_edit_authentification
    if @team.owner_id != current_user.id
      flash.now[:notice] = I18n.t('views.messages.edit_notification')
      render :show
    end
  end
end
