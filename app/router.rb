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

  route do |r|
    r.assets
    r.public

    check_csrf!

    r.root do
      # Initialize category scores to empty, and the article to a default.
      session['category_scores'] ||= {}
      session['article'] ||= Article.default_contents
      session['article_categories'] ||= Article.default_categories

      preferences = Preferences.from_session(session)

      view "home", locals: {
        article_contents: session['article'],
        category_scores: preferences.category_scores,
        article_type: preferences.article_type,
      }
    end

    r.on "next" do
      r.post true do
        preferences = Preferences.from_params(
          params: r.params,
          article_categories: session['article_categories'],
        )

        # Save preferences to the session.
        session['article_type'] = preferences.article_type
        session['category_scores'] = preferences.compressed_category_scores

        begin
          article = Article.fetch(preferences:, session:)
        rescue OpenURI::HTTPError
          flash['error'] = "Try again! There was a problem fetching the article."

          r.redirect root_path
        else
          # Save the article to the session.
          session['article_categories'] = article.categories
          session['article'] = article.contents

          render "next_article_stream", locals: {
            article_contents: article.contents,
            category_scores: preferences.category_scores,
            article_type: preferences.article_type,
          }
        end
      end
    end
  end
end
