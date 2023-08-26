---
layout: default
---

<h1 style="margin:0 0 1rem 0">Wiki Stumble</h1>

<%# render ArticleForm.new %>

<%= render Article.new(
  title: "Arnfinn Laudal",
  description: "Norwegian mathematician",
  url: "https://en.wikipedia.org/wiki/Arnfinn_Laudal",
  excerpt: "Olav Arnfinn Laudal is a Norwegian mathematician.",
  thumbnail_source: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Arnfinn_Laudal.jpg/320px-Arnfinn_Laudal.jpg",
) %>
