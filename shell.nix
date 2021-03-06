{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  clangSupport = false;
  cudaSupport = false;

  stdenv = (with pkgs; if clangSupport then clangStdenv else gccStdenv);

  pythonPackages = pkgs.python3Packages;

  vscodeExt = (with pkgs;
    vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions;
        [
          bbenoist.Nix
          eamodio.gitlens
          ms-vscode.cpptools
          ms-python.python
          ms-python.vscode-pylance
        ] ++ vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "cmake-tools";
            publisher = "ms-vscode";
            version = "1.7.3";
            sha256 = "6UJSJETKHTx1YOvDugQO194m60Rv3UWDS8UXW6aXOko=";
          }
          {
            name = "emacs-mcx";
            publisher = "tuttieee";
            version = "0.31.0";
            sha256 = "McSWrOSYM3sMtZt48iStiUvfAXURGk16CHKfBHKj5Zk=";
          }
          {
            name = "cmake";
            publisher = "twxs";
            version = "0.0.17";
            sha256 = "CFiva1AO/oHpszbpd7lLtDzbv1Yi55yQOQPP/kCTH4Y=";
          }
        ];
    });
  pythonEnv = (with pythonPackages; # note that checkInputs are missing!
    [ numpy pybind11 ] ++ [
      #------------#
      # additional #
      #------------#
      decorator
      pyjson5
      toml
      #------------#
      # pydevtools #
      #------------#
      ipython
      pip
      pytest
      python-language-server
      mypy
      pylint
      flake8
      yapf
      black
      #---------------#
      # documentation #
      #---------------#      
      sphinx
      sphinx_rtd_theme
      nbformat
      nbconvert
      nbsphinx
    ]);
in
with pkgs;
(mkShell.override { inherit stdenv; }) rec {
  buildInputs =
    [ boost17x tbb spdlog ] ++ [
      # zstd zlib
    ] ++ [ pythonEnv ] ++ lib.optionals (stdenv.hostPlatform.isLinux) [ glibcLocales ];
  nativeBuildInputs =
    [ cmake ninja ] ++ [
      bash-completion
      #fd
      more
      cacert
      which
    ] ++ [
      # stdenv.cc.cc
      # libcxxabi        
      # astyle
      clang-tools
      cmake-format
      cmakeCurses
      emacs-nox
      gdb
      git
      gnumake
      llvm
      nixpkgs-fmt
      pkg-config
      emacs-nox
      vscodeExt
      pandoc
      typora
      vscodeExt
    ] ++ [ black jupyter pythonEnv sphinx yapf ];
  shellHook = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    export PYTHONPATH=$PWD:$PYTHONPATH
    echo ""
    echo "You may want to import the pybind11 library during development"
    echo "(assuming the project was compiled in ./b*) :"
    echo ""
    echo "export PYTHONPATH=\$(readlink -f \$PWD/b*/src/pybind* | tr '\\n' ':'):\$PYTHONPATH"
    echo ""
  '';
}
