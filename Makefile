SHELL	= /bin/bash
.ONESHELL:

DB	= json-schema-stats
CORPUS  = ../YAC/corpus
LIST    = $(CORPUS)/schema.list

.PHONY: default
default:
	@echo "make clean|clean.db|png|load…"

.PHONY: clean.db
clean.db:
	$(RM) .load
	dropdb $(DB) || true

.PHONY: clean
clean: clean.db
	$(RM) *~ .load .png
	$(RM) *.csv *.model.check *.list *.size *.sorted *.err *.png
	$(MAKE) -C $(CORPUS) clean

.PHONY: load
load: load.out

load.out: schema-sorted.csv
	createdb $(DB)
	psql $(DB) \
		-f stats-create.sql \
		-f stats-import.sql \
		-f stats-cleanup.sql \
		-f stats-validity.sql > $@

.PRECIOUS: schema.csv %.model.check

$(LIST):
	$(MAKE) -C $(CORPUS) schema.list

# processing parameters
BATCH	= 1000
P	= 10

# fix relative path
schema.list: $(LIST)
	sed -e 's,^\./,$(CORPUS)/,' < $< > $@

# where models can be found
MODELS  = ../json-model/models

%.csv: %.list
	xargs -P $(P) -L $(BATCH) \
	  ./json-schema-stats.py -d $(MODELS) < $< > $@ 2> $*.err

%-sorted.csv: %.csv
	sort -t, -k23d $< > $@

NRANDS	= 100
%.shuf: %.list
	shuf -n $(NRANDS) $< > $@

%.model.check: $(LIST)
	model=$@
	model=$(MODELS)/$${model%.check}.json
	xargs -L $(BATCH) c-check-model.py $$model < $< > $@

%.size: %.list
	xargs -L $(BATCH) stat --format "%n %s" < $< > $@

%.sorted: %.size
	sort -t' ' -k2 -n $< > $@

.PHONY: count
count: $(LIST)
	wc -l $<

.PHONY: png
png: .png

.png: load.out
	psql stats < keywords.sql
	psql stats < stats-graph.sql
	./graph-histo.py graph-size
	./graph-plot.py graph-kw-petit
	./graph-plot.py graph-kw-grand
	./graph-pie.py
	touch $@
