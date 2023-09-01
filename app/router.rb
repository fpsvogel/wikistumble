require "open-uri"

class Router < Roda
  opts[:root] = Config.root

  plugin :route_csrf, require_request_specific_tokens: false, check_header: true
  plugin :sessions, secret: Config.secret_key
  plugin :assets, css: "app.css", js: "app.js", path: Config.root.join("public"), css_dir: "", js_dir: "", timestamp_paths: true
  plugin :public
  plugin :render, views: Config.root.join("app/views")
  plugin :partials
  plugin :forme
  plugin :content_for
  plugin :link_to
  plugin :path
  plugin :flash
  plugin :turbo
  plugin :status_303 # for Turbo
  plugin :enhanced_logger if Config.development?

  path(:root, "/")
  path(:next, "/next")
  path(:theme, "/theme")

  route do |r|
    r.assets
    r.public

    check_csrf!

    r.root do
      # Initialize category scores to empty, and the articles to defaults.
      unless session['category_scores']
        session['category_scores'] = {}
        session['article'], *next_articles = Article.defaults
      end

      preferences = Preferences.from_session(session)

      # TODO if next_articles is nil (meaning the user refreshed the page),
      # open a new thread and fetch and stream next articles.

      view "home", locals: {
        article_contents: session['article'].except('categories'),
        category_scores: preferences.category_scores,
        article_type: preferences.article_type,
        next_articles: next_articles || [],
        theme: session['theme'],
      }
    end

    r.on "next" do
      r.post true do
        preferences = Preferences.from_params(
          params: r.params,
          article_categories: session['article']['categories'],
        )

        # Save preferences to the session.
        session['article_type'] = preferences.article_type
        session['category_scores'] = preferences.compressed_category_scores

        # Extract next articles (article buffer) from params.
        next_articles = r.params
          .filter { |k, _v| k.start_with?('next_article_') }
          .map { |k, v|
            attribute = k[/(?<=\d_).+/] # e.g. "title" in "next_article_0_title"

            [attribute, v]
          }
          .each_slice(6)
          .map { |slice|
            # Double quotes were replaced with two backticks in _preferences.erb
            # in order for the array of strings to be stored in an HTML attribute.
            categories = [slice.last[0], JSON.parse(slice.last[1].gsub('``', '"'))]

            [*slice[..-2], categories]
          }
          .map(&:to_h)

        # Fetch the next article if the article buffer in params is empty.
        article = next_articles.shift
        retries = 2

        until article || retries < 0 do
          begin
            article = Article.fetch(preferences:, session:).to_h
          rescue OpenURI::HTTPError
            retries -= 1
          end
        end

        # TODO open a new thread and fetch and stream next article(s) to fill the buffer.

        if article
          session['article'] = article

          render "next_article_stream", locals: {
            article_contents: session['article'].except('categories'),
            category_scores: preferences.category_scores,
            article_type: preferences.article_type,
            next_articles: next_articles,
          }
        else
          flash['error'] = "Try again! There was a problem fetching the article."

          r.redirect root_path
        end
      end
    end

    r.on "theme" do
      r.post true do
        switched_to_dark_theme = r.params.has_key?('dark-theme')

        session['theme'] = switched_to_dark_theme ? "dark" : nil

        # Use a redirect status code but without a redirect, because Turbo
        # expects a redirect. This feels hacky, but I like it better than the
        # alternatives of (a) letting a 200 response through (then an error from
        # Turbo appears in the browser console), or (b) using 422 Unprocessable
        # Entity (then the browser console shows the 422 like an error).
        # And adding "data-turbo" => false to the theme switcher form leads to
        # invalid CSRF tokens, so that's not an option.
        response.status = 303

        "" # Empty response body, so that nothing is rendered.
      end
    end
  end
end
