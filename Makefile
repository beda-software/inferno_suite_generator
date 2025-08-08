typecheck:
	steep check

lint:
	rubocop .

lint-fixes:
	rubocop . -A
