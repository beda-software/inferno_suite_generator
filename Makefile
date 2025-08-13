typecheck:
	steep check

lint:
	rubocop .

lint-fixes:
	rubocop . -A

tests:
	bundle exec rake test