class AdvancedSceneSwitcher < Formula
  desc("Automate various tasks using \"Macros\"")
  homepage("https://obsproject.com/forum/resources/advanced-scene-switcher.395/")
  url("https://github.com/WarmUpTill/SceneSwitcher/releases/download/1.31.0/advanced-scene-switcher-1.31.0-macos-universal.pkg")
  sha256("a52cad3773c1bc5c3b80f3e756fd61ee40ec5c05eab83b0025d444e0f03a0c23")
  license("GPL2")
  version("1.31.0")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/advanced-scene-switcher.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
