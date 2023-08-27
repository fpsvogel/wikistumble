# Form object for article preferences. Will change once preferences are handled
# reactively via Turbo Streams.
class ArticleForm
  # Creates a new ArticleForm based on information saved in the session.
  # @param session [Hash]
  # @return [ArticleForm]
  def self.from_session(session)
    new(
      # Uncompress category scores, changing the keys from indexes into names.
      category_scores: session['category_scores']
        .transform_keys { |index| OresCategories.all[Integer(index)] },
      article_type: session['article_type']&.to_sym || :any,
    )
  end

  # Creates a new ArticleForm based on the submitted form.
  # @param params [Hash]
  # @return [ArticleForm]
  def self.from_submit(params)
    new(
      # Nest submitted category scores under a single key.
      category_scores: params
        .filter { |k, v| k.start_with?("category_score_") }
        .transform_keys { |k| k.delete_prefix("category_score_") }
        .transform_values(&:to_i)
        .sort_by { |_category, score| -score } # descending order
        .to_h,
      article_type: params['article_type'],
      reaction: params['reaction'],
    )
  end

  # @param category_scores [Hash]
  # @param article_type [String]
  # @param reaction [String] 'like' or 'dislike'
  def initialize(category_scores:, article_type:, reaction: nil)
    @category_scores = category_scores
    @article_type = article_type
    @reaction = reaction
  end

  # Attributes to render in the form.
  # @return [Hash]
  def attributes_to_render
    {
      category_scores: @category_scores,
      article_type: @article_type,
    }
  end

  # Saves the form's attributes to the session, specifically the attributes
  # that are rendered in the form.
  # @param session [Hash]
  # @param article_categories [Hash]
  def save(session, article_categories = nil)
    session['article_type'] = @article_type

    add_reaction_into_category_scores(article_categories)
    # Compress category scores, changing the keys from names into indexes.
    session['category_scores'] = @category_scores
      .transform_keys { |name| OresCategories.all.index(name) }
  end

  private

  # For each of the article's categories, applies +1 or -1 (like/dislike) to the
  # category score.
  def add_reaction_into_category_scores(article_categories)
    step = { "like" => 1, "dislike" => -1}[@reaction]
    return unless step

    (article_categories || []).each do |article_category|
      existing_category_score = @category_scores.fetch(article_category, 0)
      new_category_score = existing_category_score + step

      @category_scores[article_category] = new_category_score
    end
  end
end