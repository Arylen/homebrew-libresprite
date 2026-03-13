class Libresprite < Formula
  desc "Free and open source pixel art and sprite animation editor"
  homepage "https://libresprite.github.io/"
  url "https://github.com/LibreSprite/LibreSprite.git",
      tag:      "v1.1",
      revision: "dce8cfe7b6d366fe0ae8f3b35740c0f9e2e4d9e0"
  license "GPL-2.0-only"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "giflib"
  depends_on "gnutls"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libpng"
  depends_on "webp"
  depends_on "pixman"
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "tinyxml2"
  depends_on "zlib"

  on_macos do
    depends_on xcode: :build
  end

  def install
    # Ensure submodules are initialised (Homebrew clones with --depth=1)
    system "git", "submodule", "update", "--init", "--recursive"

    mkdir "build" do
      args = std_cmake_args + %W[
        -G Ninja
        -DUSE_SHARED_TINYXML2=ON
        -DUSE_SHARED_PIXMAN=ON
        -DUSE_SHARED_FREETYPE=ON
        -DUSE_SHARED_GIFLIB=ON
        -DUSE_SHARED_JPEGLIB=ON
        -DUSE_SHARED_ZLIB=ON
        -DUSE_SHARED_LIBPNG=ON
        -DUSE_SHARED_LIBWEBP=ON
        -DUSE_SHARED_LIBARCHIVE=ON
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        -DCMAKE_PREFIX_PATH=#{Formula["libarchive"].opt_prefix}
      ]

      if OS.mac?
        sdk = MacOS::CLT.installed? ? "" : MacOS.sdk_path.to_s
        args << "-DCMAKE_OSX_SYSROOT=#{sdk}" unless sdk.empty?
      end

      system "cmake", "..", *args
      system "ninja", "libresprite"

      # Install the binary and data
      bin.install "bin/libresprite"
      prefix.install Dir["bin/data"] if File.directory?("bin/data")
    end
  end

  def caveats
    <<~EOS
      LibreSprite has been installed as a command-line binary.
      Run it with:
        libresprite

      If you want an app bundle in /Applications, you can create
      a wrapper with Automator or a shell script .app bundle.
    EOS
  end

  test do
    # LibreSprite needs a display; just verify the binary exists and runs
    assert_match "LibreSprite", shell_output("#{bin}/libresprite --version 2>&1", 1)
  end
end
