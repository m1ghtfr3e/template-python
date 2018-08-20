SOURCE_FILES = Makefile cookiecutter.json {{cookiecutter.project_name}}/* {{cookiecutter.project_name}}/*/*
GENERATED_PROJECT := TemplateDemo

ENV := .venv

# MAIN #########################################################################

.PHONY: all
all: install

.PHONY: ci
ci: build
	make doctor ci -C $(GENERATED_PROJECT)

.PHONY: watch
watch: install clean
	poetry run sniffer

# DEPENDENCIES #################################################################

.PHONY: install
install: $(ENV)
$(ENV): pyproject.*
ifdef CI
	poetry install --no-dev
else
	poetry install
endif
	@ touch $@

# BUILD ########################################################################

_COOKIECUTTER_INPLACE = cookiecutter.json > tmp && mv tmp cookiecutter.json

.PHONY: build
build: install $(GENERATED_PROJECT)
$(GENERATED_PROJECT): $(SOURCE_FILES)
ifeq ($(TEST_RUNNER),nose)
	sed "s/pytest/nose/g" $(_COOKIECUTTER_INPLACE)
else ifeq ($(TEST_RUNNER),pytest)
	sed "s/nose/pytest/g" $(_COOKIECUTTER_INPLACE)
endif
	sed "s/master/python3-pytest/g" $(_COOKIECUTTER_INPLACE)
	cat cookiecutter.json
	poetry run cookiecutter . --no-input --overwrite-if-exists
	sed "s/python3-pytest/master/g" $(_COOKIECUTTER_INPLACE)
	cd $(GENERATED_PROJECT) && poetry lock
	@ touch $(GENERATED_PROJECT)

# CLEANUP ######################################################################

.PHONY: clean
clean:
	rm -rf $(GENERATED_PROJECT)

.PHONY: clean-all
clean-all: clean
	rm -rf $(ENV)
