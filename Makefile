BUILD_DIR = ./build
SRC_DIR = ./src
SRCS = $(shell ls $(SRC_DIR)/*.tex)
SHELL_DIR = ./shell

MAIN_TEX = $(SRC_DIR)/thesis.tex
MAIN_PDF = $(MAIN_TEX:$(SRC_DIR)/%.tex=$(BUILD_DIR)/%.pdf)

REDPEN := $(if $(REDPEN),$(REDPEN),redpen --conf redpen-conf.xml --result-format xml)

.PHONY: build
build: $(MAIN_PDF)

.PHONY: $(MAIN_PDF)
$(MAIN_PDF): $(BUILD_DIR)/$(SRC_DIR)
	latexmk -pdfdvi $(PREVIEW_CONTINUOUSLY) -use-make $(MAIN_TEX)

# build/src ディレクトリがないとビルドに失敗する
$(BUILD_DIR)/$(SRC_DIR):
	mkdir -p $@

.PHONY: watch
watch: PREVIEW_CONTINUOUSLY=-pvc
watch: build

.PHONY: redpen
redpen: redpen.ja redpen.en

redpen.%: $(shell echo $(SRC_DIR)/*.%.tex)
	$(REDPEN) \
	--result-format xml \
	--lang ja \
	--conf redpen/redpen-conf-$(subst redpen.,,$@).xml \
	$^ > build/$@.xml
	@echo "<!-- generated by 'make $@' -->" >> build/$@.xml

.PHONY: clean
clean:
	@$(RM) -rf $(BUILD_DIR)/*

.PHONY: lint
lint:
	npm install -D textlint-rule-no-mix-dearu-desumasu
	npm install -D textlint-rule-no-dropping-the-ra
	npm install -D textlint-rule-preset-ja-technical-writing
	npm install -D textlint-plugin-latex2e
	npm install -D textlint-filter-rule-comments
	npm run lint

.PHONY: convert-img-pdf
convert-img-pdf:
	sh $(SHELL_DIR)/convert-img-pdf.sh

.PHONY: build-with-convert-img
build-with-convert-img:
	make convert-img-pdf 
	make build

.PHONY: word_count
word_count:
	detex ./src/thesis.tex | wc -m
	detex ./src/thesis.tex | wc -w

# .PHONY: sed-punctuation
# sed-punctuation:
# 	sh $(SHELL_DIR)/sed-punctuation.sh