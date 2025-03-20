class Regtest < Formula
  desc "Small utility to run bitcoin-sv regtest on a mac"
  homepage "https://github.com/ordishs/bitcoin-sv-regtest"
  url "https://github.com/ordishs/bitcoin-sv-regtest/releases/1.0.0.tar.gz"
  sha256 "386fcdb8ee1e59d4eb79e80178b540e9d288fd3b3e073c21a4fd074efe4d40d4"
  version "1.0.0"

  def install
    bin.install "regtest"
    bin.install "regtest_wallet.dat"
  end
end