class CommentsController < ApplicationController
  # def create
  #   @post = Post.find(params[:post_id])
  #   @comment = @post.comments.create(params[:comment].permit(:name, :body))

  #   redirect_to post_path(@post)
  # end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to @post
    else
      flash.now[:danger] = 'error'
    end
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
