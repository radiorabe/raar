class PodcastBuilder < Nokogiri::XML::Builder

  include Rails.application.routes.url_helpers

  def initialize(user, show, audio_files)
    super()
    @user = user
    @show = show
    @audio_files = audio_files
  end

  def to_xml
    generate
    super
  end

  private

  def generate
    channel_container do
      static_headers
      dynamic_headers
      @audio_files.each do |file|
        item do
          item_elements(file)
        end
      end
    end
  end

  def channel_container
    rss('xmlns:atom' => 'http://www.w3.org/2005/Atom',
        'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd',
        'version' => '2.0') do
      channel do
        yield
      end
    end
  end

  def static_headers
    link 'https://archiv.rabe.ch'
    language 'de-ch'
    copyright "&#xA9; #{Time.zone.now.year}"
    logo
    self['atom'].link(href: '', rel: 'self', type: 'application/rss+xml')
  end

  def logo
    image do
      url 'http://rabe.ch/wp-content/uploads/2016/05/logo_rabe_orange_weiss.jpg'
      title 'RaBe 95.6 MHz'
      link 'http://rabe.ch'
    end
  end

  def dynamic_headers
    pubDate @audio_files.first.broadcast.started_at
    title @show.name
    description @show.details
  end

  def item_elements(file)
    title "#{@show.name} - #{file.broadcast}"
    description file.broadcast.details
    enclosure(url: audio_url(file), type: file.audio_encoding.mime_type, length: 1)
    guid audio_url(file)
    pubDate file.broadcast.started_at
  end

  def audio_url(file)
    options = AudioPath.new(file).url_params
    options[:api_token] = user.api_token if @user && @user.api_token
    options[:access_code] = user.access_code if @user && @user.access_code
    audio_file_path(options)
  end

end

=begin
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
 xmlns:itunesu="http://www.itunesu.com/feed" version="2.0">
<channel>
<link>http://www.YourSite.com</link>
<language>en-us</language>
<copyright>&#xA9;2013</copyright>
<webMaster>your@email.com (Your Name)</webMaster>
<managingEditor>your@email.com (Your Name)</managingEditor>
<image>
<url>http://www.YourSite.com/ImageSize300X300.jpg</url>
<title>Title or description of your logo</title>
<link>http://www.YourSite.com</link>
</image>
<itunes:owner>
<itunes:name>Your Name</itunes:name>
<itunes:email>your@email.com</itunes:email>
</itunes:owner>
<itunes:category text="Education">
<itunes:category text="Higher Education" />
</itunes:category>
<itunes:keywords>separate, by, comma, and, space</itunes:keywords>
<itunes:explicit>no</itunes:explicit>
<itunes:image href="http://www.YourSite.com/ImageSize300X300.jpg" />
<atom:link href="http://www.YourSite.com/feed.xml" rel="self" type="application/rss+xml" />
<pubDate>Sun, 01 Jan 2012 00:00:00 EST</pubDate>
<title>Verbose title of the podcast</title>
<itunes:author>College, school, or department owning the podcast</itunes:author>
<description>Verbose description of the podcast.</description>
<itunes:summary>Duplicate of above verbose description.</itunes:summary>
<itunes:subtitle>Short description of the podcast - 255 character max.</itunes:subtitle>
<lastBuildDate>Thu, 02 Feb 2012 00:00:00 EST</lastBuildDate>
<item>
<title>Verbose title of the episode</title>
<description>Verbose description of the episode.</description>
<itunes:summary>Duplicate of above verbose description.</itunes:summary>
<itunes:subtitle>Short description of the episode - 255 character max.</itunes:subtitle>
<itunesu:category itunesu:code="112" />
<enclosure url="http://www.YourSite.com/FILE.EXT" type="audio/mpeg" length="1" />
<guid>http://www.YourSite.com/FILE.EXT</guid>
<itunes:duration>H:MM:SS</itunes:duration>
<pubDate>Thu, 02 Feb 2012 00:00:00 EST</pubDate>
</item>
</channel>
</rss>
=end
