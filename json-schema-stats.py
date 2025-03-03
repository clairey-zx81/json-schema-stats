#! /usr/bin/env python
#
# TODO
# - FIXME dangling refs with - or . chars?
# - many lists shoud be sets
# - change vm* format? collect where/why??
# - https://github.com/orgs/json-schema-org/discussions/323
# - https://github.com/json-schema-org/json-schema-spec/issues/1079
# - https://github.com/ssilverman/snowy-json#the-linter

import re
import json
import logging
import argparse
from urllib.parse import unquote as url_unquote

from json_model.stats import JsonType, json_metrics, json_metrics_raw
from json_model.utils import is_regex, distinct_values
from json_model.dynamic_compiler import compileModel

from jsutils.stats import json_schema_stats, normalize_ods

logging.basicConfig()
log = logging.getLogger("stats")
log.setLevel(logging.INFO)
# log.setLevel(logging.DEBUG)

# handle options and arguments
ap = argparse.ArgumentParser()
ap.add_argument("-d", "--model-dir", help="JSON Model directory")
ap.add_argument("-n", "--no-csv", action="store_true", help="Generate JSON output instead of CSV")
ap.add_argument("schemas", nargs="*", help="JSON Schema to analyze")
args = ap.parse_args()

import sys
import csv

csv_out = None if args.no_csv else csv.writer(sys.stdout)

import hashlib

def shash(s: str):
    return hashlib.sha3_256(s.encode()).hexdigest()[:20]

JSON_MODELS = args.model_dir or "./json-model/models"

JSON_MODEL_FILES = [
    "draft-01.model.json",
    "draft-01-nesting.model.json",
    "draft-02.model.json",
    "draft-02-nesting.model.json",
    "draft-03.model.json",
    "draft-03-nesting.model.json",
    "draft-03-fuzzy.model.json",
    "draft-04.model.json",
    "draft-04-nesting.model.json",
    "draft-04-fuzzy.model.json",
    # there is no official meta schema for Draft 5
    "draft-06.model.json",
    "draft-06-fuzzy.model.json",
    "draft-07.model.json",
    "draft-07-fuzzy.model.json",
    "draft-2019-09.model.json",        # aka Draft 8
    "draft-2019-09-fuzzy.model.json",  # aka Draft 8
    "draft-2020-12.model.json",
    "draft-2020-12-fuzzy.model.json",
    "draft-next.model.json",
    "draft-next-fuzzy.model.json",
    # FIXME tighter?
    "draft-tight.model.json",  # restrictions in analysis paper
]

JSON_CHECKS = []
for fn in JSON_MODEL_FILES:
    log.info(f"loading model: {fn}")
    with open(f"{JSON_MODELS}/{fn}") as f:
        jmodel = json.load(f)
        JSON_CHECKS.append(compileModel(jmodel))

for fn in args.schemas:
    log.info(f"considering: {fn}")
    # hardwired:-/
    try:
        path = fn.split("/")
        source = path[4]
    except IndexError:
        source = "<unknown>"
    with open(fn) as f:
        try:
            # raw data and its hash
            data = f.read()
            rhash = shash(data)
            jdata = json.loads(data)

            # basic JSON structural stats
            jm = json_metrics(jdata, JsonType.SCHEMA)

            # all validations…
            valids = [ check(jdata) for check in JSON_CHECKS ]

            # JSON Schema specific stats
            stats = json_schema_stats(jdata)
            small = { k: v for k, v in stats.items() if v or isinstance(v, bool) }
            js_stats = json.dumps(small, sort_keys=True)

            # normalized version with its hash
            normalize_ods(fn, jdata)  # OpenDataSoft generated schemas
            normed = json.dumps(jdata, sort_keys=True, indent=None)
            nhash = shash(normed)

            if csv_out:
                row = valids + [
                    stats["<version>"],
                    fn, source,
                    # deduplication helpers
                    rhash, nhash,
                    # depth
                    jm[0],
                    # raw json
                    jm[5]['null'], jm[5]['boolean'], jm[5]['integer'], jm[5]['number'],
                    jm[5]['string'], jm[5]['array'], jm[5]['object'],
                    jm[5]['#items'], jm[5]['#props'], jm[5]['#length'],
                    # json length
                    jm[4],
                    # detailed stats
                    js_stats
                ]
                csv_out.writerow(row)
            else:
                # print(f"// input: {fn}")
                # print(f"// {json_metrics(jdata, JsonType.SCHEMA)}")
                # print(json.dumps(small, sort_keys=True, indent=2))
                small["<input-file>"] = fn
                small["<json-metrics>"] = json_metrics_raw(jdata, JsonType.SCHEMA)
                print(json.dumps(small, sort_keys=True, indent=2))
        except Exception as e:
            log.error(f"{fn}: {e}", exc_info=True)
