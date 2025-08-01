class RetroEffects < Formula
  desc("Provides several filters to simulate retro hardware")
  homepage("https://obsproject.com/forum/resources/retro-effects.1972/")
  url("https://obsproject.com/forum/resources/retro-effects.1972/version/5708/download?file=105079")
  sha256("d69c891c61f0360a39309f067ba9b76a7e364e6ca1debeb595c53cc2ba2ddceb")
  license("GPL2")
  version("1.0.0")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/obs-retro-effects.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
