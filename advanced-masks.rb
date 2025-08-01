class AdvancedMasks < Formula
  desc("Enhance your OBS Studio masking capabilities with advanced masking filters")
  homepage("https://obsproject.com/forum/resources/advanced-masks.1856/")
  url("https://obsproject.com/forum/resources/advanced-masks.1856/version/6385/download?file=114778")
  sha256("0cdadd2a66897cadc62263ee1165555c8d4bc88cfd6d9a1e55a6fbcea234591f")
  license("GPL2")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/obs-advanced-masks.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
