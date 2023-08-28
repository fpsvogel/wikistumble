# A container for a Wikipedia article's categories and summary contents.
class Article
  attr_reader :categories

  # Fetches a new Wikipedia article and saves it and its categories to the session.
  # @param preferences [Preferences]
  # @param session [Hash]
  # @return [Article] the new Article.
  def self.fetch_and_save!(preferences:, session:)
    article = new(**preferences.attributes)

    session['article_categories'] = article.categories
    session['article'] = article.contents

    article
  end

  # The default article that appears when the app is first opened (or when
  # the user clears their session). This prevents a long first load time.
  # @return [Hash]
  def self.default_contents
    {
      title: "Rotating locomotion in living systems",
      description: "Rotational self-propulsion of organisms",
      url: "https://en.wikipedia.org/wiki/Rotating_locomotion_in_living_systems",
      extract: "Several organisms are capable of rolling locomotion. However, true wheels and propellers—despite their utility in human vehicles—do not seem to play a significant role in the movement of living things. Biologists have offered several explanations for the apparent absence of biological wheels, and wheeled creatures have appeared often in speculative fiction.",
      thumbnail_source: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Wheeled_animal_-_East_Mexico_cultures_-_Ethnological_Museum%2C_Berlin_-_DSC00852.JPG/320px-Wheeled_animal_-_East_Mexico_cultures_-_Ethnological_Museum%2C_Berlin_-_DSC00852.JPG",
    }
  end

  # The categories of the above default article.
  # @return [Array<String>]
  def self.default_categories
    ["STEM.STEM*", "STEM.Biology", "History and Society.History", "Culture.Literature"]
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
    }
  end
end
