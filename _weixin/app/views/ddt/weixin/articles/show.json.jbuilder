json.extract! @article, :title, :introduction, :description
json.image @article.image_variant(:medium)
json.created_at @article.created_at.strftime("%Y-%m-%d %H:%M")