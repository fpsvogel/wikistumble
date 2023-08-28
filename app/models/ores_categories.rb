# Categories of Wikipedia articles according to ORES (https://ores.wikimedia.org).
class OresCategories
  DEFAULT = [
    "Culture.Biography.Biography*",
    "Culture.Biography.Women",
    "Culture.Visual arts.Visual arts*",
    "History and Society.History",
  ]

  # All categories, from https://www.mediawiki.org/wiki/ORES/Articletopic
  # @return [Array(String)]
  def self.all
    @all ||=
      ["Culture.Biography.Biography*",
      "Culture.Biography.Women",
      "Culture.Food and drink",
      "Culture.Internet culture",
      "Culture.Linguistics",
      "Culture.Literature",
      "Culture.Media.Books",
      "Culture.Media.Entertainment",
      "Culture.Media.Films",
      "Culture.Media.Media*",
      "Culture.Media.Music",
      "Culture.Media.Radio",
      "Culture.Media.Software",
      "Culture.Media.Television",
      "Culture.Media.Video games",
      "Culture.Performing arts",
      "Culture.Philosophy and religion",
      "Culture.Sports",
      "Culture.Visual arts.Architecture",
      "Culture.Visual arts.Comics and Anime",
      "Culture.Visual arts.Fashion",
      "Culture.Visual arts.Visual arts*",
      "Geography.Geographical",
      "Geography.Regions.Africa.Africa*",
      "Geography.Regions.Africa.Central Africa",
      "Geography.Regions.Africa.Eastern Africa",
      "Geography.Regions.Africa.Northern Africa",
      "Geography.Regions.Africa.Southern Africa",
      "Geography.Regions.Africa.Western Africa",
      "Geography.Regions.Americas.Central America",
      "Geography.Regions.Americas.North America",
      "Geography.Regions.Americas.South America",
      "Geography.Regions.Asia.Asia*",
      "Geography.Regions.Asia.Central Asia",
      "Geography.Regions.Asia.East Asia",
      "Geography.Regions.Asia.North Asia",
      "Geography.Regions.Asia.South Asia",
      "Geography.Regions.Asia.Southeast Asia",
      "Geography.Regions.Asia.West Asia",
      "Geography.Regions.Europe.Eastern Europe",
      "Geography.Regions.Europe.Europe*",
      "Geography.Regions.Europe.Northern Europe",
      "Geography.Regions.Europe.Southern Europe",
      "Geography.Regions.Europe.Western Europe",
      "Geography.Regions.Oceania",
      "History and Society.Business and economics",
      "History and Society.Education",
      "History and Society.History",
      "History and Society.Military and warfare",
      "History and Society.Politics and government",
      "History and Society.Society",
      "History and Society.Transportation",
      "STEM.Biology",
      "STEM.Chemistry",
      "STEM.Computing",
      "STEM.Earth and environment",
      "STEM.Engineering",
      "STEM.Libraries & Information",
      "STEM.Mathematics",
      "STEM.Medicine & Health",
      "STEM.Physics",
      "STEM.STEM*",
      "STEM.Space",
      "STEM.Technology"]
  end
end