.PHONY: typecheck lint lint-fixes tests check

typecheck:
	steep check

lint:
	rubocop .

lint-fixes:
	rubocop . -A

tests:
	bundle exec rake test

check:
	$(MAKE) lint
	$(MAKE) typecheck
	$(MAKE) tests