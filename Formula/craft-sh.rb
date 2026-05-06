class CraftSh < Formula
  desc "Command-line tool for quick capture to Craft Documents"
  homepage "https://github.com/gdamberg/craft.sh"
  url "https://github.com/gdamberg/craft.sh/archive/refs/tags/v#{version}.tar.gz"
  sha256 "PLACEHOLDER"
  license "MIT"
  version "1.0.0"

  def install
    bin.install "craft.sh"
  end

  test do
    assert_match "craft.sh", shell_output("#{bin}/craft.sh --help")
  end
end
