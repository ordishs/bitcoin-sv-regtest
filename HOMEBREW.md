To publish on Homebrew:

git tag v1.0.1

git push --tags

git archive --format=tar.gz --output=bitcoin-sv-regtest-1.0.1.tar.gz v1.0.1 regtest regtest_wallet.dat 

gh release create v1.0.1 bitcoin-sv-regtest-1.0.1.tar.gz --title "Bitcoin SV Regtest 1.0.1" --notes "Latest release of Bitcoin SV Regtest."

# Get the SHA256 hash of the release
curl -L https://github.com/ordishs/bitcoin-sv-regtest/releases/download/v1.0.1/bitcoin-sv-regtest-1.0.1.tar.gz | shasum -a 256


Edit regtest.rb in github.com/ordishs/homebrew-regtest to update tar name and sha


