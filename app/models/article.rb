# A container for a Wikipedia article's categories and summary contents.
class Article
  attr_reader :categories

  # Fetches a new Wikipedia article and saves it and its categories to the session.
  # @param session [Hash]
  # @param form [ArticleForm]
  # @return [Article] the new Article.
  def self.fetch_and_save!(session, form)
    article = new(**form.attributes)

    session['article_categories'] = article.categories
    session['article'] = article.contents

    article
  end

  # @param category_scores [Hash]
  # @param article_type [String, Symbol]
  def initialize(category_scores:, article_type:)
    api = Wikipedia.new(category_scores:, article_type:)
    summary, @categories = api.fetch_summary_and_categories

    @title = summary["title"]
    @description = summary["description"]
    @extract = summary["extract"]
    @url = summary.dig("content_urls", "desktop", "page")
    @thumbnail_source = summary.dig("thumbnail", "source")
    @related_articles = api.related_articles(summary)
  end

  # Everything except @categories.
  # @return [Hash]
  def contents
    {
      title: @title,
      description: @description,
      url: @url,
      extract: @extract,
      thumbnail_source: @thumbnail_source,
      related_articles: @related_articles,
    }
  end
end
