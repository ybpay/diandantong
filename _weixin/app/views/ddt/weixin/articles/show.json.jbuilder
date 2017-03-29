json.extract! @article, :title, :introduction, :description
json.image @article.image.medium.url
json.created_at @article.created_at.strftime("%Y-%m-%d %H:%M")