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
      # RM these temporary defaults after reactive (Turbo Streams) category scores are implemented
      unless session['category_scores']
        session['category_scores'] = Categories::DEFAULT
        .map { |category| [Categories.all.index(category), 10] }
        .to_h
      end

      form = ArticleForm.from_session(session)
      article_contents = session['article'] ||
        Article.fetch_and_save!(session, form).contents

      view "home", locals: { **form.attributes, article_contents: }
    end

    r.on "next" do
      r.post true do
        form = ArticleForm.from_submit(r.params)
        article = Article.fetch_and_save!(session, form)
        form.save!(session, article.categories)

        r.redirect root_path
      end
    end
  end
end
