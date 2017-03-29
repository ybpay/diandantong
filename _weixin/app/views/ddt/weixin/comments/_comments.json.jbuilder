json.array! comments do |comment|
  json.extract! comment, :id, :content, :created_at, :rating
  json.nickname comment.owner.comment_owner_label rescue '匿名'
  if comment.comment.present?
    json.comments do
      json.partial! partial: '/ddt/weixin/comments/comments', locals: { comments: [comment.comment] }
    end
  end
end
