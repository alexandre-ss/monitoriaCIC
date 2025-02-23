##
# Implementação da controller de Turmas
# Função: definir métodos estruturais para listagem, criação, inserção de dados,
# edição de um registro e remoção de um registro

class TurmasController < ApplicationController

  def new
    @user = current_user
  end

  def edit
    @turma = Turma.find(params[:id])
  end

  def create
    @turma = Turma.create(turma_params)

    if !@turma.errors.any?
      flash[:notice] = 'Turma cadastrada com sucesso!'
    else
      flash[:danger] = @turma.errors.full_messages
    end

    redirect_to dashboard_turmas_path
  end

  ##
  # Método responsável por atualizar um registro com os dados inseridos em Edit.
  #
  # Recebe os dados da view Edit e faz o tratamento dos dados modificados pelo usuário.
  #
  # Caso os dados sejam válidos, o registro é atualizado no banco e
  # Redireciona para a página de turmas.
  #
  # Caso os dados sejam inválidos, o registro não é atualizado no banco e
  # Redireciona para a página turmas com a mensagem de erro.
  #
	# PATCH/PUT /turmas/:id
  def update
    @turma = Turma.find(params[:id])
    if validate_turma(turma_params[:qnt_bolsas]) == true
      @turma.update_attributes(turma_params)
      if !@turma.errors.any?
        flash[:notice] = 'Turma atualizada com sucesso!'
      else
        flash[:danger] = @turma.errors.full_messages
      end
      redirect_to dashboard_turmas_path
    else
      flash[:notice] = 'Turma possui uma quantidade de alunos aceito maior que a nova quantidade de vagas disponiveis!'
      redirect_to dashboard_turmas_path
    end
  end

  def destroy
    @turma = Turma.find(params[:id])
    Monitoria.find_each do |m|
      if m.fk_turmas_id == @turma.id
        m.destroy
      end
    end
    @turma.destroy
    flash[:notice] = 'Turma apagada com sucesso!'
    redirect_to dashboard_turmas_path
  end

  private
  def turma_params
    params.require(:turma).permit(:id, :turma, :professor, :fk_cod_disciplina, :qnt_bolsas, :fk_vagas_id)
  end

  def find_turma
    @turma = Turma.find(params[:id])
  end

  def self.get_turmas(professor)
    @turmas = Array.new
    @turmas_buscadas = Turma.find_each do |turma|
      if turma.professor == professor.name
        @turmas << turma
      end
    end
    @turmas
  end

  def validate_turma(quantidade)
    @monitoria = Monitoria.where(fk_turmas_id: params[:id], fk_status_monitoria_id: 3)
    turma = quantidade.to_i
    return true if @monitoria.length <= turma || @monitoria.length == 0
  end
end
