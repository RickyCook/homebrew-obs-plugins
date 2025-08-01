class CompositeBlur < Formula
  desc("A comprehensive blur plugin that provides blur algorithms and types for all levels of quality and computational need")
  homepage("https://obsproject.com/forum/resources/composite-blur.1780/")
  url("https://obsproject.com/forum/resources/composite-blur.1780/version/6384/download?file=114774")
  sha256("16d6ed9a84baf647fd7c91c18266405033b018a8e3dd82730249582619307b3a")
  license("GPL2")
  version("1.5.2")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/obs-composite-blur.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
