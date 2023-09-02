class ParamsHelper
  # Extracts next articles from the params hash, where they are stored flat
  # rather than nested, with keys and values like this:
  #   "next_article_<unique-id>_<attribute>" => "<value>"
  # @param params [Hash]
  # @return [Array<Hash>] an array of hashes with the keys Article.attributes.map(&:to_s)
  def self.next_articles(params)
    params
      .filter { |k, _v| k.start_with?('next_article_') }
      .map { |k, v|
        attribute = k[/(?<=\d_)[a-z_]+/] # e.g. "title" in "next_article_26485.2632_title"

        [attribute, v]
      }
      .each_slice(Article.attributes.count)
      .map { |slice|
        # Double quotes were replaced with two backticks in _next_article_hidden_inputs.erb
        # in order for the array of strings to be stored in an HTML attribute.
        categories = [slice.last[0], JSON.parse(slice.last[1].gsub('``', '"'))]

        [*slice[..-2], categories]
      }
      .map(&:to_h)
  end
end
