class CraftSh < Formula
  desc "Command-line tool for quick capture to Craft Documents"
  homepage "https://github.com/gdamberg/craft.sh"
  url "https://github.com/gdamberg/craft.sh/archive/refs/tags/0.9.1.tar.gz"
  sha256 "7da6ac6b6655e38b458305a475cbc938aa89d435fcaa829e3cca544e203a2ae5"
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
