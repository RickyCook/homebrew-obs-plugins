class MediaPlaylistSource < Formula
  desc("An alternative to VLC Video Source")
  homepage("https://obsproject.com/forum/resources/media-playlist-source.1765/")
  url("https://github.com/CodeYan01/media-playlist-source/releases/download/0.1.3/media-playlist-source-0.1.3-macos-universal.pkg")
  sha256("47d23c9f985bc49ef37ab1a8830f7de5ff6335122af240d3e8e04e4e479acf30")
  license("GPL2")
  version("0.1.3")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/media-playlist-source.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
