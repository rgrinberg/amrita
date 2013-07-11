VENDORED_ELIXIR=${PWD}/vendor/elixir/bin/elixir
VENDORED_MIX=${PWD}/vendor/elixir/bin/mix
RUN_VENDORED_MIX=${VENDORED_ELIXIR} ${VENDORED_MIX}
VERSION := $(strip $(shell cat VERSION))
ELIXIR_VERSION = 0.9.3

.PHONY: all test

all: clean test

clean:
	mix clean

test:
	MIX_ENV=test mix do deps.get, test

docs:
	MIX_ENV=dev mix deps.get
	git checkout gh-pages && git pull --rebase && git rm -rf docs && git commit -m "remove old docs"
	git checkout master
	elixir -pa ebin deps/ex_doc/bin/ex_doc "Amrita" "${VERSION}" -u "https://github.com/josephwilk/amrita"
	git checkout gh-pages && git add docs && git commit -m "adding new docs" && git push origin gh-pages
	git checkout master

ci: ci_$(ELIXIR_VERSION) ci_master

vendor_$(ELIXIR_VERSION):
	@rm -rf vendor/*
	@mkdir -p vendor/elixir
	@wget --no-clobber -q http://dl.dropbox.com/u/4934685/elixir/v$(ELIXIR_VERSION).zip && unzip -qq v$(ELIXIR_VERSION).zip -d vendor/elixir

vendor_master:
	@rm -rf vendor/*
	@mkdir -p vendor/elixir
	git clone https://github.com/elixir-lang/elixir.git vendor/elixir
	make --quiet -C vendor/elixir

ci_master: vendor_master
	@${VENDORED_ELIXIR} --version
	@MIX_ENV=test ${RUN_VENDORED_MIX} do deps.get, test

ci_$(ELIXIR_VERSION): vendor_$(ELIXIR_VERSION)
	@${VENDORED_ELIXIR} --version
	@MIX_ENV=test ${RUN_VENDORED_MIX} do deps.get, test

test_vendored:
	@${VENDORED_ELIXIR} --version
	@MIX_ENV=test ${RUN_VENDORED_MIX} do deps.get, test
