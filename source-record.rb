class SourceRecord < Formula
  desc("Record a source using a filter")
  homepage("https://obsproject.com/forum/resources/source-record.1285/")
  url("https://obsproject.com/forum/resources/source-record.1285/version/6239/download?file=113214")
  sha256("16108ee4647447918860718aa4a579d88e366d84c70f116179cb45562541eaa0")
  license("GPL2")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/source-record.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
