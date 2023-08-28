class Router < Roda
  opts[:root] = Config.root

  plugin :sessions, secret: Config.secret_key
  plugin :assets, css: "app.css", js: "app.js", path: Config.root.join("public"), css_dir: "", js_dir: "", timestamp_paths: true
  plugin :render, views: Config.root.join("app/views")
  plugin :partials
  plugin :route_csrf, require_request_specific_tokens: false, check_header: true
  plugin :flash
  plugin :link_to
  plugin :path
  plugin :status_303 # for Turbo
  plugin :turbo
  # plugin :forme_set, secret: Config.secret_key
  plugin :forme
  plugin :content_for
  plugin :typecast_params
  plugin :enhanced_logger if Config.development?
  plugin :public

  path(:root, "/")
  path(:next, "/next")

  route do |r|
    r.assets
    r.public

    check_csrf!

    r.root do
      preferences = Preferences.new(session:)
      article_contents = session['article'] ||
        Article.fetch_and_save!(preferences:, session:).contents

      view "home", locals: { **preferences.attributes, article_contents: }
    end

    r.on "next" do
      r.post true do
        preferences = Preferences.new(params: r.params)
        preferences.save!(session)

        article = Article.fetch_and_save!(preferences:, session:)

        r.redirect root_path
      end
    end
  end
end
