# A container for a Wikipedia article's categories and summary contents.
class Article
  # @return [Array<Symbol>]
  def self.attributes
    [:title, :description, :url, :extract, :thumbnail_source, :categories]
  end

  # Fetches a new Wikipedia article and extracts its contents and categories
  # into a new Article object.
  # @param preferences [Preferences]
  # @return [Article] the new Article.
  def self.fetch(preferences:, session:)
    new(
      article_type: preferences.article_type,
      category_scores: preferences.category_scores,
    )
  end

  # The default articles that are loaded into the queue to appear when the app
  # is first opened (or when the user clears their session). This prevents a
  # long first load time.
  # @return [Hash]
  def self.defaults
    [
      {
        'title' => "Rotating locomotion in living systems",
        'description' => "Rotational self-propulsion of organisms",
        'url' => "https://en.wikipedia.org/wiki/Rotating_locomotion_in_living_systems",
        'extract' => "Several organisms are capable of rolling locomotion. However, true wheels and propellers—despite their utility in human vehicles—do not seem to play a significant role in the movement of living things. Biologists have offered several explanations for the apparent absence of biological wheels, and wheeled creatures have appeared often in speculative fiction.",
        'thumbnail_source' => "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Wheeled_animal_-_East_Mexico_cultures_-_Ethnological_Museum%2C_Berlin_-_DSC00852.JPG/320px-Wheeled_animal_-_East_Mexico_cultures_-_Ethnological_Museum%2C_Berlin_-_DSC00852.JPG",
        'categories' => ["STEM.STEM*", "STEM.Biology", "History and Society.History", "Culture.Literature"],
      },
      {
        'title' => "Wife selling (English custom)",
        'description' => "17th–?19th-Cent custom for publicly ending an unsatisfactory marriage",
        'url' => "https://en.wikipedia.org/wiki/Wife_selling_(English_custom)",
        'extract' => "Wife selling in England was a way of ending an unsatisfactory marriage that probably began in the late 17th century, when divorce was a practical impossibility for all but the very wealthiest. After parading his wife with a halter around her neck, arm, or waist, a husband would publicly auction her to the highest bidder. Wife selling provides the backdrop for Thomas Hardy's 1886 novel The Mayor of Casterbridge, in which the central character sells his wife at the beginning of the story, an act that haunts him for the rest of his life, and ultimately destroys him.",
        'thumbnail_source' => "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Microcosm_of_London_Plate_006_-_Auction_Room%2C_Christie%27s_%28colour%29.jpg/320px-Microcosm_of_London_Plate_006_-_Auction_Room%2C_Christie%27s_%28colour%29.jpg",
        'categories' => ["Geography.Geographical", "Geography.Regions.Europe.Europe*", "History and Society.Society"],

      },
      {
        'title' => "The Million Dollar Homepage",
        'description' => "Website",
        'url' => "https://en.wikipedia.org/wiki/The_Million_Dollar_Homepage",
        'extract' => "The Million Dollar Homepage is a website conceived in 2005 by Alex Tew, a student from Wiltshire, England, to raise money for his university education. The home page consists of a million pixels arranged in a 1000 × 1000 pixel grid; the image-based links on it were sold for $1 per pixel in 10 × 10 blocks. The purchasers of these pixel blocks provided tiny images to be displayed on them, a URL to which the images were linked, and a slogan to be displayed when hovering a cursor over the link. The aim of the website was to sell all the pixels in the image, thus generating a million dollars of income for the creator. The Wall Street Journal has commented that the site inspired other websites that sell pixels.",
        'thumbnail_source' => "https://upload.wikimedia.org/wikipedia/en/3/3f/The_Million_Dollar_Homepage.png",
        'categories' => ["Culture.Internet culture", "Culture.Media.Media*", "History and Society.Business and economics", "STEM.STEM*", "STEM.Technology"],
      },
    ]
  end

  # @param article_type [String, Symbol]
  # @param category_scores [Hash]
  def initialize(article_type:, category_scores:)
    api = Wikipedia.new(article_type:, category_scores:)
    summary, @categories = api.fetch_summary_and_categories

    @title = summary["title"]
    @description = summary["description"]
    @extract = summary["extract"]
    @url = summary.dig("content_urls", "desktop", "page")
    @thumbnail_source = summary.dig("thumbnail", "source")
  end

  # @return [Hash]
  def to_h
    self.class.attributes
      .map { [_1.to_s, instance_variable_get("@#{_1}")] }
      .to_h
  end
end
