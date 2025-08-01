class Shaderfilter < Formula
  desc("Allow users to apply their own shaders to OBS sources")
  homepage("https://obsproject.com/forum/resources/obs-shaderfilter.1736/")
  url("https://github.com/exeldro/obs-shaderfilter/releases/download/2.5.1/obs-shaderfilter-2.5.1-macos-universal.pkg")
  sha256("9ccae575283a06c289f4516632669d058c26797877b98a1274aaca7dd208dca9")
  license("GPL2")
  version("2.5.1")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/obs-shaderfilter.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
