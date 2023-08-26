class Article < Bridgetown::Component
  def initialize(**kwargs)
    @title = kwargs[:title]
    @description = kwargs[:description]
    @url = kwargs[:url]
    @excerpt = kwargs[:excerpt]
    @thumbnail_source = kwargs[:thumbnail_source]
  end
end
