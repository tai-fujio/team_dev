class AgendasController < ApplicationController
  # before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end
  
  def destroy
    @team = Team.find(params[:team_id])
    @agenda = Agenda.find(params[:id])
    if @agenda.destroy
      flash.now[:notice] = I18n.t('views.messages.agenda_deleted')
      render template: 'teams/show' and return
    else
      flash.now[:error] = I18n.t('views.messages.agenda_not_deleted')
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
end
