# frozen_string_literal: true

module Api
  class ListsController < BaseController
    acts_as_token_authentication_handler_for User
    before_action :find_list, only: %i[show update destroy]

    def index
      @lists = current_user.lists
    end

    def show; end

    def create
      @list = List.new(list_params)
      @list.user = current_user
      if @list.save
        render :show, status: :created
      else
        render_error
      end
    end

    def update
      if @list.update(list_params)
        render :show
      else
        render_error
      end
    end

    def destroy
      @list.destroy
      head :no_content
    end

    private

    def list_params
      params.permit(:title, :color)
    end

    def find_list
      @list = List.find(params[:id])
    end

    def render_error
      render json: { errors: @list.errors.full_messages },
             status: :unprocessable_entity
    end
  end
end
