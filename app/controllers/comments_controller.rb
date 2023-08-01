# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]

  # POST /reports/:report_id/comments or books
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    @comment.save
    redirect_to @commentable, notice: 'Comment was successfully created.'
  end

  # DELETE /reports/:report_id/comments/:id or books
  def destroy
    @comment.destroy
    redirect_to @commentable, notice: 'Comment was successfully destroyed'
  end

  private

  def set_comment
    @comment = current_user.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
