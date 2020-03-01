class Gcovr < Formula
  desc "Reports from gcov test coverage program"
  homepage "https://gcovr.com/"
  url "https://github.com/gcovr/gcovr/archive/4.2.tar.gz"
  sha256 "589d5cb7164c285192ed0837d3cc17001ba25211e24933f0ba7cb9cf38b8a30e"
  head "https://github.com/gcovr/gcovr.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "4c1f761c118737ad2f786b20433f8ffb62344ed0449ba4c57d3316c1e87dace4" => :catalina
    sha256 "375d5736d80f9843b2a77d86b365d123a472325c6c8cd3c68d065bce99d8c9bf" => :mojave
    sha256 "b5b3a5c643c84b547e6c2ae0c9db6cba7d53a8a081e080eb1efefcfd1f95b211" => :high_sierra
    sha256 "7cf8abff45bbea6e268fe4674c5f8ff2be1d4df413abf3068def0f07c2bc0c09" => :sierra
    sha256 "8044508fa650772d5d00cd83a8eacebf0cd910b2ced77e693809dbb8a0fdcb34" => :el_capitan
  end

  depends_on "python@3.8"

  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/d8/03/e491f423379ea14bb3a02a5238507f7d446de639b623187bccc111fbecdf/Jinja2-2.11.1.tar.gz"
    sha256 "93187ffbc7808079673ef52771baa950426fd664d3aad1d0fa3e95644360e250"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/39/2b/0a66d5436f237aff76b91e68b4d8c041d145ad0a2cdeefe2c42f76ba2857/lxml-4.5.0.tar.gz"
    sha256 "8620ce80f50d023d414183bf90cc2576c2837b88e00bea3f33ad2630133bbb60"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz"
    sha256 "29872e92839765e546828bb7754a68c418d927cd064fd4708fab9fe9c8bb116b"
  end

  def install
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"
    resources.each do |r|
      r.stage do
        system "python3", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system "python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"example.c").write "int main() { return 0; }"
    system "cc", "-fprofile-arcs", "-ftest-coverage", "-fPIC", "-O0", "-o",
                 "example", "example.c"
    assert_match "Code Coverage Report", shell_output("#{bin}/gcovr -r .")
  end
end
