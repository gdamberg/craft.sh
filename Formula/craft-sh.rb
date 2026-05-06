class CraftSh < Formula
  desc "Command-line tool for quick capture to Craft Documents"
  homepage "https://github.com/gdamberg/craft.sh"
  url "https://github.com/gdamberg/craft.sh/archive/refs/tags/1.0.0.tar.gz"
  sha256 "701cc76d291eba968fef242470fe674c713ac8ce2202339e0f659c89558a7676"
  license "MIT"

  depends_on "jq"

  def install
    bin.install "craft.sh"
    bash_completion.install "completions/craft.bash" => "craft.sh"
    zsh_completion.install "completions/_craft" => "_craft.sh"
    fish_completion.install "completions/craft.fish" => "craft.sh.fish"
  end

  test do
    assert_match "craft.sh", shell_output("#{bin}/craft.sh --help")
  end
end
