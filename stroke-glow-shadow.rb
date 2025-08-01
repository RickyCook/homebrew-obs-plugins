class StrokeGlowShadow < Formula
  desc("An efficient way to apply Stroke, Glow, and Shadow effects to masked sources")
  homepage("https://obsproject.com/forum/resources/stroke-glow-shadow.1800/")
  url("https://obsproject.com/forum/resources/stroke-glow-shadow.1800/version/6168/download?file=112272")
  sha256("e206944c6645bd289805ececb42190e036e32b9cf19136347cd5a692ca1d11de")
  license("GPL2")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/obs-stroke-glow-shadow.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
