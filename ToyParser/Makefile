PROJECT ?= ToyParser.xcodeproj
SCHEME ?= ToyParser
DESTINATION ?= platform=macOS
DERIVED_DATA_PATH ?= /private/tmp/ToyParserDerivedData

.PHONY: test
test:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination "$(DESTINATION)" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		-only-testing:ToyParserTests
