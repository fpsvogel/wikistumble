require "net/http"
require "open-uri"
require "json"

# A wrapper for the Wikipedia API calls used to create an Article.
# The APIs used:
#   - Wikimedia REST API (https://www.mediawiki.org/wiki/Wikimedia_REST_API)
#       for article summaries.
#   - Random page in category (https://randomincategory.toolforge.org)
#       for random good or featured articles.
#   - LiftWing (https://wikitech.wikimedia.org/wiki/Machine_Learning/LiftWing)
#     formerly ORES (https://ores.wikimedia.org)
#       for article categories.
class Wikipedia
  MAX_ARTICLE_QUERIES = 10
  CANDIDATE_CHANCE = 2 # Multiplied by (candidate_score / top_category_score)
  # to get a probability that a candidate will be selected early, before
  # MAX_ARTICLE_QUERIES is reached.

  # @param article_type [String, Symbol]
  # @param category_scores [Hash]
  def initialize(article_type:, category_scores:)
    @article_type = article_type
    @category_scores = category_scores
  end

  # Fetches an article summary and its categories.
  # @return [Array(Hash, Array(String))]
  def fetch_summary_and_categories
    candidates = []

    (1..MAX_ARTICLE_QUERIES).each do |query_n|
      article = random_article(type: @article_type)
      category_predictions, category_probabilities = categories(Integer(article['revision']))
      score = candidate_score(category_predictions, category_probabilities, @category_scores)

      candidates << [article, category_predictions, score]

      return candidates.last if good_enough_candidate?(score, @category_scores)
    end

    candidates.max_by(&:last)[0..1]
  end

  private

  # Fetches the summary of a random article.
  # @param type [String, Symbol] any, good, or featured.
  # @return [Hash] the article summary.
  def random_article(type: :any)
    if type.nil? || type.to_sym == :any
      summary_url = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
      JSON.parse(URI.open(summary_url).read)
    else # good or featured
      random_better_article(type)
    end

  rescue OpenURI::HTTPError => e
    if Config.development?
      # debugger # TODO diagnose problem
      raise e
    else
      raise e
    end
  end

  # Fetches the summary of a random good or featured article.
  # @param type [String, Symbol] good or featured.
  # @return [Hash] the article summary.
  def random_better_article(type)
    redirect_url = URI("https://randomincategory.toolforge.org/#{type.to_s.capitalize}_articles")
    redirect = Net::HTTP.get_response(redirect_url)
    article_url = redirect['location']
    title = article_url.split("/").last
    summary_url = "https://en.wikipedia.org/api/rest_v1/page/summary/#{title}"

    JSON.parse(URI.open(summary_url).read)
  rescue URI::InvalidURIError
    JSON.parse(URI.open(URI::DEFAULT_PARSER.escape(summary_url)).read)
  end

  # Fetches the predicted categories of an article, as well as the probabilities
  # of all categories. (The predicted categories are the ones with the highest
  # probabilities.)
  # @param revision_id [Integer] an article's revision ID.
  # @return [Array(Array<String>, Hash{String => Float})] the category predictions and probabilities.
  def categories(revision_id)
    categories_url = "https://api.wikimedia.org/service/lw/inference/v1/models/enwiki-articletopic:predict"

    uri = URI(categories_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = { rev_id: revision_id }.to_json

    response = JSON.parse(http.request(request).body)

    # TODO sometimes .values causes a NoMethodError for nil
    # (but this seems not to happen anymore?)
    ["prediction", "probability"].map { |key|
      response.dig("enwiki", "scores").values.first.dig("articletopic", "score", key)
    }
  end

  # Scores a candidate article based on its predicted categories, their
  # probabilities, and the user's category scores.
  # @param category_predictions [Array<String>]
  # @param category_probabilities [Hash{String => Float}]
  # @param category_scores [Hash{String => Integer}]
  # @return [Float]
  def candidate_score(category_predictions, category_probabilities, category_scores)
    category_predictions.map { |category|
      category_probabilities[category] * (category_scores[category] || 0)
    }.sum
  end

  # Determines whether a candidate article is good enough to be used.
  # @param candidate_score [Float]
  # @param category_scores [Hash{String => Integer}]
  # @return [Boolean]
  def good_enough_candidate?(candidate_score, category_scores)
    return false if candidate_score < 0
    return true if category_scores.empty?

    top_category_score = category_scores.values.max
    probability = CANDIDATE_CHANCE * (candidate_score / top_category_score)
    probability > 1 || rand < probability
  end
end
