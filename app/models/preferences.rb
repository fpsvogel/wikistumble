# Article preferences, inputted via a form.
class Preferences
  attr_reader :category_scores, :article_type

  # Initializes Preferences with values saved in the session.
  # @param session [Hash]
  # @return [Preferences]
  def self.from_session(session)
    new(
      category_scores: decompress_category_scores_from_session(session),
      article_type: session['article_type']&.to_sym || :any,
    )
  end

  # Category scores are compressed when they're saved to the session, so they
  # need to be decompressed when they're retrieved from the session.
  # @param category_scores [Hash] a hash of category indexes to scores
  #   (including only the keys that have non-zero values).
  # @return [Hash] a hash of all category names to scores.
  private_class_method def self.decompress_category_scores_from_session(session)
    # Change the keys from indexes into names, then sort by score (descending
    # order) and by category name.
    category_scores = session['category_scores']
      .transform_keys { |index| Categories.all[Integer(index)] }
      .transform_values!(&:to_i)
      .sort_by { |category, score| [-score, category] }
      .to_h

    # Add zeroes (last in order) for any categories that were omitted from the session.
    zero_category_scores = Categories.all.map { |category| [category, 0] }.to_h
    category_scores.merge(zero_category_scores) { |_key, existing, _zero| existing }
  end

  # Initializes Preferences with values submitted in a form to params.
  # @param params [Hash]
  # @param article_categories [Hash] from the session.
  # @return [Preferences]
  def self.from_params(params:, article_categories:)
    new(
      category_scores: extract_category_scores_from_params(params, params['reaction'], article_categories),
      article_type: params['article_type'] || :any,
    )
  end

  # Extracts submitted category scores from params, where they are stored with
  # a prefix rather than nested in their own hash. Then adjusts them bason on
  # user reaction (like/dislike). Finally, sorts them.
  # @param params [Hash]
  # @params reaction [String, nil] "+" or "-".
  # @param article_categories [Hash] from the session.
  # @return [Hash]
  private_class_method def self.extract_category_scores_from_params(params, reaction, article_categories)
    category_scores = params
      .filter { |k, v| k.start_with?("category_score_") }
      .transform_keys { |k| k.delete_prefix("category_score_") }
      .transform_values(&:to_i)

    # Adjust category scores based on user reaction.
    step = { "+" => 1, "-" => -1}[reaction] || 0

    article_categories.each do |article_category|
      existing_category_score = category_scores.fetch(article_category, 0)
      new_category_score = existing_category_score + step

      category_scores[article_category] = new_category_score
    end

    # Sorts by descending score (except zeroes appear last), then by category name.
    category_scores
      .reject { |_category, score| score.zero? }
      .sort_by { |category, score| [-score, category] }
      .concat(
        category_scores
          .filter { |_category, score| score.zero? }
          .sort_by { |category, _score| category }
      )
      .to_h
  end

  # @category_scores [Hash] a hash of category names to scores.
  # @article_type [String, Symbol] any, good, or featured.
  def initialize(category_scores:, article_type:)
    @category_scores = category_scores
    @article_type = article_type
  end

  # Category scores in compressed form, for efficient saving to the session.
  # @return [Hash] a hash of category indexes to scores (including only the
  #   keys that have non-zero values).
  def compressed_category_scores
    @category_scores
      .reject { |_category, score| score.zero? }
      .transform_keys { |name| Categories.all.index(name) }
  end
end