# Article preferences, input via forms.
class ArticlePreferences
  # Initializes ArticlePreferences with values submitted in a form to params,
  # filling in any missing values from the session.
  # @param session [Hash]
  # @param params [Hash]
  def initialize(session:, params: {})
    @category_scores = retrieve_category_scores(session, params)
    @article_type = params['article_type'] || session['article_type']&.to_sym || :any
    @reaction = params['reaction']
  end

  # @reaction is omitted because it's ancillary, temporarily stored only in
  # order to influence @category_scores.
  # @return [Hash]
  def attributes
    {
      category_scores: @category_scores,
      article_type: @article_type,
    }
  end

  # Saves the form's attributes to the session, specifically the attributes
  # that are rendered in the form.
  # @param session [Hash]
  # @param article_categories [Hash]
  def save!(session)
    session['article_type'] = @article_type

    add_reaction_into_category_scores(session)
    # Compress category scores, changing the keys from names into indexes.
    session['category_scores'] = @category_scores
      .transform_keys { |name| Categories.all.index(name) }
  end

  private

  # If a form was submitted, use the submitted values in `params`. Otherwise,
  # use the values saved in the session.
  # @param session [Hash]
  # @param params [Hash]
  # @return [Hash]
  def retrieve_category_scores(session, params)
    if params.keys.any? { |key| key.start_with?('category_score') }
      # Nest submitted category scores under a single key.
      category_scores = params
        .filter { |k, v| k.start_with?("category_score_") }
        .transform_keys { |k| k.delete_prefix("category_score_") }
    else
      # Initialize category scores to zero.
      session['category_scores'] ||= (0..Categories.all.count - 1).map { |i| [i, 0] }.to_h

      # Uncompress category scores, changing the keys from indexes into names.
      category_scores = session['category_scores']
        .transform_keys { |index| Categories.all[Integer(index)] }
    end

    category_scores
      .transform_values(&:to_i)
      .sort_by { |category, score| [-score, category] } # descending score order, then alphabetical
      .to_h
  end

  # For each of the article's categories, applies +1 or -1 (like/dislike) to the
  # category score.
  def add_reaction_into_category_scores(session)
    step = { "+" => 1, "-" => -1}[@reaction]
    return unless step

    session['article_categories'].each do |article_category|
      existing_category_score = @category_scores.fetch(article_category, 0)
      new_category_score = existing_category_score + step

      @category_scores[article_category] = new_category_score
    end
  end
end