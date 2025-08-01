class Move < Formula
  desc("Move sources to a new position during scene transition")
  homepage("https://obsproject.com/forum/resources/move.913/")
  url("https://obsproject.com/forum/resources/move.913/version/6373/download?file=114667")
  sha256("5d7287307a5bd796ee03c5533235eecdec8de816f5272f29cd73d94a68629d97")
  license("GPL2")
  version("3.1.5")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/move-transition.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
