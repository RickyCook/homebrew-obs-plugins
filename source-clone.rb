class SourceClone < Formula
  desc("Lets you clone sources to allow different filters than the original")
  homepage("https://obsproject.com/forum/resources/source-clone.1632/")
  url("https://obsproject.com/forum/resources/source-clone.1632/version/5627/download?file=104022")
  sha256("738ff83481f491c9c52c9fd886bf3a1adec8e18a543b14da45daeab526daa5e8")
  license("GPL2")

  def install
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/source-clone.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
