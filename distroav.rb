class Distroav < Formula
  desc("Simple audio/video input and output over IP using NDI® technology")
  homepage("https://obsproject.com/forum/resources/distroav-network-audio-video-in-obs-studio-using-ndi%C2%AE-technology.528/")
  url("https://github.com/DistroAV/DistroAV/releases/download/6.1.1/distroav-6.1.1-macos-universal.pkg")
  sha256("119e88377a3920216ac2f9e29b174d45c43f855baed14c7b282e35378c0e06d3")
  license("GPL2")

  def install
    brew = "#{HOMEBREW_PREFIX}/bin/brew"
    cask_versions = `#{brew} list --versions --cask`.lines
    ndi_line = cask_versions.find { |l,|
      l.start_with?("libndi ")
    }
    unless ndi_line
      odie("The cask 'libndi' must be installed first. Run: brew install --cask libndi")
    end
    pkg_files = Dir.glob("*-universal.pkg")
    system("installer", "-pkg", pkg_files.[](0), "-target", "CurrentUserHomeDirectory")
    plugin_path = "#{Dir.home}/Library/Application Support/obs-studio/plugins/distroav.plugin"
    link_path = "#{prefix}/#{File.basename(plugin_path)}"
    if File.exist?(link_path)
      File.delete(link_path)
    end
    File.symlink(plugin_path, link_path)
  end
end
