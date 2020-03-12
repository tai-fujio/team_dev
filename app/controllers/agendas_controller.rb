class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]
  before_action :destroy_authentication, only: %i[destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def destroy
    if @agenda.destroy
      @agenda.team.members.each{|member|
      AgendaDeletedNotifyMailer.agenda_deleted_notify(@agenda,member.email).deliver
      }
      flash.now[:notice] = I18n.t('views.messages.agenda_deleted')
      render template: 'teams/show' and return
    else
      flash.now[:notice] = I18n.t('views.messages.agenda_not_deleted')
      render template: 'teams/show' and return
    end
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda') 
    else
      render :new
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end

  def destroy_authentication
    @team = Team.find(params[:team_id])
    @agenda = Agenda.find(params[:id])
    unless @agenda.user_id == current_user.id || @agenda.team.owner_id == current_user.id
      flash.now[:notice] = I18n.t('views.messages.delete_authentication_notice')
      render template: 'teams/show'
    end
  end
end
