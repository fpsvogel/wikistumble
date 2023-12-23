require "open-uri"

class Router < Roda
  opts[:root] = Config.root

  plugin :route_csrf, require_request_specific_tokens: false, check_header: true
  plugin :sessions, secret: Config.secret_key
  plugin :assets, css: "app.css", js: "app.js", path: Config.root.join("public"), css_dir: "", js_dir: "", timestamp_paths: true
  plugin :public
  plugin :render, views: Config.root.join("app/views")
  plugin :partials
  plugin :forme_route_csrf
  plugin :content_for
  plugin :link_to
  plugin :path
  plugin :flash
  plugin :turbo
  plugin :status_303 # for Turbo
  plugin :enhanced_logger if Config.development?

  MAX_NEXT_ARTICLES = 10 # size of the next articles buffer
  FETCH_RETRIES = 2

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

      view "home", locals: {
        article_contents: session['article'].except('categories'),
        category_scores: preferences.category_scores,
        article_type: preferences.article_type,
        next_articles: next_articles || [],
        max_next_articles: MAX_NEXT_ARTICLES,
        theme: session['theme'],
      }
    end

    r.on "next" do
      r.post true do
        preferences = Preferences.from_params(
          params: r.params,
          article_categories: session['article']['categories'],
        )

        session['article_type'] = preferences.article_type
        session['category_scores'] = preferences.compressed_category_scores

        next_articles = ParamsHelper.next_articles(r.params)
        article = next_articles.shift

        # Immediately fetch the next article if the buffer from params is empty.
        retries = FETCH_RETRIES
        until article || retries < 0 do
          begin
            article = Article.fetch(preferences:).to_h
          rescue
            retries -= 1
          end
        end

        if article
          session['article'] = article

          render "next_article_stream", locals: {
            article_contents: session['article'].except('categories'),
            category_scores: preferences.category_scores,
          }
        else
          flash['error'] = "Try again! There was a problem fetching the article."

          r.redirect root_path
        end
      end

      # The next articles buffer (hidden inputs in the form) is filled via SSE
      # (server-sent events) streamed responses to GET /next, after POST /next
      # has shown the next buffered article. This way, the POST isn't blocked by
      # the Wikipedia API calls, which can take several seconds.
      r.get true do
        # # These headers aren't necessary in my case, but I've seen them
        # # recommended for SSE:
        # # I would need to set content type, except it's set in StreamHelper.
        # response['Content-Type'] = 'text/event-stream'
        # response['X-Accel-Buffering'] = 'no' # if deploying to Nginx
        # response['Cache-Control'] = 'no-cache'
        # response['Connection'] = 'keep-alive'
        # response['Transfer-Encoding'] = 'identity'

        # Updated preferences have already been saved to the session by POST /next.
        preferences = Preferences.new(
          category_scores: session['category_scores'],
          article_type: session['article_type'],
        )

        StreamHelper.async_stream(request:) do |out|
          next_article = nil
          retries = FETCH_RETRIES
          until next_article || retries < 0 do
            begin
              next_article = Article.fetch(preferences:).to_h
            rescue
              retries -= 1
            end
          end

          if next_article
            # Buffer the newly fetched article by replacing the first
            # <turbo-stream-source> with hidden inputs containing the article.
            turbo_replace = turbo_stream.replace_all(
              "#next-articles > turbo-stream-source:first-of-type",
              partial(
                "partials/next_article_hidden_inputs",
                # id for unique input names in the form.
                locals: { article: next_article, id: Time.now.to_f },
              ),
            )

            out.write("data: #{turbo_replace.gsub("\n", ' ')}\n\n")
          end
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

        "" # empty response body so that nothing is rendered
      end
    end
  end
end
