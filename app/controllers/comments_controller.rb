class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    redirect_to post_path(@post)
    # @post.comments.create(comment_params.merge(user_id: current_user.id))
    #   	respond_with post, comment
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id, :post_id)
  end
end
