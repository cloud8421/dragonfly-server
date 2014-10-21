.PHONY: setup

setup:
	curl -o bin/goon https://github.com/alco/goon/releases/download/v1.1.1/goon_darwin_386.tar.gz
	mix deps.get
