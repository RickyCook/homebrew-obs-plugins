class GradientSource < Formula
  desc("Gradient Source for OBS studio")
  homepage("https://obsproject.com/forum/resources/gradient-source.1172/")
  url("https://obsproject.com/forum/resources/gradient-source.1172/version/4964/download?file=95248")
  sha256("4f00af8fd6922f5c466cc5e013691d1feb00703b616a5d0c3d4451ce6ae91d78")
  license("GPL2")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/gradient-source.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
