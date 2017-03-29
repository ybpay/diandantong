#encoding: utf-8
module Ddt
  module Backend
    class Admin::JokesController < Ddt::Backend::BaseAdminController
      before_action :set_joke, only: [:edit, :update]
      def index
        @jokes = Ddt::Joke.all.paginate(page: params[:page], :per_page => 25)
      end

      def new
        @joke = Ddt::Joke.new
      end

      def create
        @joke = Ddt::Joke.new(joke_params)
        if @joke.save
          redirect_to [:backend, :jokes]
        else
          render :new
        end
      end

      def edit

      end

      def update
        if @joke.update(joke_params)
          redirect_to [:backend, :jokes]
        else
          render :edit
        end
      end

      def destroy
        @joke.destroy
        redirect_to [:backend, :jokes]
      end

      private
      def joke_params
        params.require(:joke).permit(:content)
      end

      def set_joke
        @joke = Ddt::Joke.find(params[:id])
      end
    end
  end
end