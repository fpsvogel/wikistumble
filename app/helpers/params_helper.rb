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
      .map(&:to_h)
      .map { |hash|
        hash.transform_values.with_index { |v, i|
          if i == Article.attributes.index(:categories)
            # Change backticks back into double quotes; see _next_article_hidden_inputs.erb.
            # The same is done for the article contents in _article.erb.
            JSON.parse(v.gsub('``', '"'))
          else
            v
          end
        }
      }
  end
end
