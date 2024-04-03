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

from json_model.utils import JsonType, json_metrics, json_metrics_raw, is_regex
from json_model.compiler import compileModel, distinct_values

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

# Properties names which suggest a JSON schema
DOUBTFUL_PROPERTY_NAMES = {
    "$vocabulary", "exclusiveMinimum", "exclusiveMaximum", "multipleOf",
    "prefixItems", "additionalItems",
    "minContains", "maxContains", "unevaluatedItems",
    "properties", "minProperties", "maxProperties", "patternProperties", "additionalProperties",
    "unevaluatedProperties", "dependentRequired", "propertyNames",
    "allOf", "anyOf", "oneOf"
}

# PER TYPE PROPERTIES
PER_TYPE = {
    # out: $ref and $dynamicRef type
    "hyper": [ "base", "links", "href", "rel" ],  # Draft 3 Section 6 Hyper Schema (partial)
    "meta": [ "$schema", "$vocabulary", "$id", "$anchor", "$dynamicAnchor", "$comment",
                "title", "description", "default", "examples", "deprecated", "readOnly", "writeOnly", "id",
                "context", "notes" ],
    "alone": [ "enum", "const" ],
    # number also stands for integer
    "number": [ "minimum", "maximum", "exclusiveMinimum", "exclusiveMaximum", "multipleOf", "divisibleBy" ],
    "string": [ "minLength", "maxLength", "pattern", "contentMediaType", "contentEncoding", "contentSchema" ],
    "array": [ "items", "prefixItems", "additionalItems", "minItems", "maxItems",
                "uniqueItems", "contains", "minContains", "maxContains", "unevaluatedItems" ],
    "object": [ "properties", "minProperties", "maxProperties", "patternProperties", "additionalProperties",
                "unevaluatedProperties", "required-list", "dependentRequired", "propertyNames" ],
    "combi": [ "allOf", "anyOf", "oneOf", "if", "then", "else", "not" ],
}

PROP_TO_TYPE = {}
for t, props in PER_TYPE.items():
    for prop in props:
        PROP_TO_TYPE[prop] = t

# value is not a schema
SCHEMA_KEYS_SIMPLE = [
    # core
    "$schema", "$vocabulary", "$id", "$anchor", "$dynamicAnchor", "$ref", "$dynamicRef",
    "$comment",
    # metadata
    "title", "description", "default", "examples", "deprecated", "readOnly", "writeOnly",
    # types
    "type", "enum", "const", "format",
    # validation
    "minimum", "maximum", "multipleOf", "exclusiveMaximum", "exclusiveMinimum",
    "minLength", "maxLength", "minItems", "maxItems", "minProperties", "maxProperties",
    "pattern", "minContains", "maxContains", "uniqueItems",
    "contentMediaType", "contentEncoding", "contentSchema",
    "required", "dependentRequired",
    # UNSURE, OLD?
    "id", "context", "notes", "optional", "base", "links", "rel", "href", "requires",
]

SCHEMA_KEYS_VALUE_SCHEMA = [
    "not", "if", "then", "else", "items", "contains", "additionalProperties",
    "propertyNames", "unevaluatedItems", "unevaluatedProperties",
    # OLD?
    # beware of dependencies which is both Schema or {"": [""]}
    "additionalItems", "dependencies", "extends",
]

SCHEMA_KEYS_ARRAY_OF_SCHEMAS = [
    "allOf", "anyOf", "oneOf", "prefixItems",
    # OLD
    "items", "extends",
]

SCHEMA_KEYS_OBJECT_VALUES_SCHEMAS = [
    "$defs", "definitions", # old version
    "dependentSchemas", "properties", "patternProperties",
]

# typical typos…
SCHEMA_KEYS_TYPOS = [
    "typeof", "min", "max", "comment", "_comment", "comments", "minSize", "maxSize", "example", "readonly", "writeonly",
    "desription", "despcription", "descritpion", "descrition", "decription", "descrption", "descripiton", "descripition",
    "decsription", "descripion", "Description", "unique", "@type", "defaults", "$default", "ContentType",
    "schema", "schemas", "link", "constant", "required:", "minimum:", "maximum:", "Schema", "Default", "Type",
    "$type", "ref", "@id", "_id", "refs", "__ref", "#ref", "type:", "$allOf", "$anyOf", "$oneOf", "anyof", "allof", "oneof",
    "AllOf", "OneOf", "AnyOf", "$types", "#/anyOf", "#/allOf", "#/oneOf", "$extend", "$extends", "$rel",
    "read-only", "write-only", "minitems", "maxitems", "maxLen", "minLen", "maxValue", "minValue", "max_length", "min_length",
    "maxlength", "minlength", "minLenght", "maxLenght", "regex", "allOf:indexes: 1", "allOf:indexes: 0", "$version", "Ref",
    "numItems", "require", "patterns", "properites", "$deprecated", "deprecation", "requiredProperties", "property", "Id",
    "minimal", "maximal", "inclusiveMinimum", "inclusiveMaximum", "Comment", "$refs", "enums", "Minimum", "Maximum", "totalItems",
    "additional_properties", "prefix",
]

# "type" is managed manually
SPECIAL_VALUES = [ "$schema" ]

SPECIALS = [
    # boolean JSON schema, empty schema
    "true", "false", "{}",
    # also some values or constructs
    "type-list", "type-list-one", "type-list-empty",
    "type=null", "type=boolean", "type=integer", "type=number", "type=string", "type=array", "type=object",
    "items-list",
    "additionalProperties=true", "additionalItems=true",
    "additionalProperties=false", "additionalItems=false",
    "exclusiveMinimum=true", "exclusiveMinimum=false",
    "exclusiveMaximum=true", "exclusiveMaximum=false",
    "required-count", "required=true", "required=false", "required-empty", "required-list", "required-bool",
    "allOf-count", "anyOf-count", "oneOf-count", "prefixItems-count", "items-count",
    "allOf-one", "anyOf-one", "oneOf-one", "prefixItems-one", "items-one", "enum-one",
    "allOf-empty", "anyOf-empty", "oneOf-empty", "prefixItems-empty", "items-empty", "enum-empty",
    # schemas
    "properties-count", "patternProperties-count", "dependentSchemas-count",
    "$defs-count", "definitions-count", "extends-count", "extends-one",
    # missing?
    "<unknown>", "<typos>", "<version>",
]

INTEGER_KEYWORDS = [
    "minItems", "maxItems",
    "minProperties", "maxProperties",
    "minLength", "maxLength",
    "minContains", "maxContains",
]

NUMBER_KEYWORDS = [
    "minimum", "maximum"
]

FORMATS = [
    "date", "date-time", "time", "duration",
    "email", "idn-email",
    "hostname", "idn-hostname", "ipv4", "ipv6",
    "uri", "uri-reference", "uri-template",
    # what is an iri is beyond comprehension, and has been removed
    "iri", "iri-reference",
    "uuid",
    "json-pointer", "relative-json-pointer",
    "regex",
    # OLD
    "color", "phone",
]

# NOTE there are other formats in other OpenAPI versions?
OPENAPI_310_FORMATS = [
    "int32", "int64", "float", "double", "password"
]

OPENAPI_310_KEYWORDS = [
    "discriminator", "xml", "externalDocs", "example"
]

# collected sets need to be changed to lists for json serialization
SETS = [
    "<typos-keywords>", "<typos-keywords-where>", "<unknown-keywords>",
    "<errors>", "<bad-properties-nesting-where>", "<openapi>", "<extensions>",
]

# all expected schema keys to initialize
SCHEMA_KEYS = (
    SCHEMA_KEYS_SIMPLE +
    SCHEMA_KEYS_VALUE_SCHEMA +
    SCHEMA_KEYS_ARRAY_OF_SCHEMAS +
    SCHEMA_KEYS_OBJECT_VALUES_SCHEMAS +
    SPECIALS
)

#
# VERSION GUESSING
#

CURRENT_VERSION = 9
NEXT_VERSION = CURRENT_VERSION + 1
LATEST_VERSION = NEXT_VERSION + 1

# explicit version identification in $schema
# 0 for not set, -1 if multiply set; error?
SCHEMA_VERSIONS = {
    "/draft-01/": 1,
    "/draft-02/": 2,
    "/draft-03/": 3,
    "/draft-04/": 4,
    "/draft-05/": 5,  # probably not used anywhere?
    "/draft-06/": 6,
    "/draft-07/": 7,
    "/draft-08/": 8,
    "/draft-2019-09/": 8,
    "/draft/2019-09/": 8,
    "/draft-2020-12/": 9,
    "/draft/2020-12/": 9,
    "/draft-next/": NEXT_VERSION,
    "/draft/next/": NEXT_VERSION,
    "json-schema.org/schema": LATEST_VERSION,
}

# version specific keywords which help guessing the schema
# note: some keywords type can also help guessing…
# items list vs simple schema
# formats…
SCHEMA_VERSION_GUESS = {
  # TODO boolean schemas, *BUT* problems with "additional{Items,Properties}"…
  "type=any": [1, 2, 3],
  "requires": [1, 2],
  "required-bool": [3],
  "required-list": [4, 5, 6, 7, 8, 9],
  "exclusiveMinimum=true": [3, 4],
  "exclusiveMinimum=false": [3, 4],
  "exclusiveMaximum=true": [3, 4],
  "exclusiveMaximum=false": [3, 4],
  "items-list": [1, 2, 3, 4, 5, 6, 7, 8],  # 8: deprecated?
  "maxDecimal": [1],
  "optional": [1, 2],
  "additionalItems": [3, 4, 5, 6, 7, 8],  # 8: deprecated?
  "prefixItems": [9],
  "minimumCanEqual": [1, 2],
  "maximumCanEqual": [1, 2],
  "contentEncoding": [1, 2, 7, 8, 9],  # disappear then reappears!
  "exclusiveMinimum": [3, 4, 5, 6, 7, 8, 9],
  "exclusiveMaximum": [3, 4, 5, 6, 7, 8, 9],
  "patternProperties": [3, 4, 5, 6, 7, 8, 9],
  "divisibleBy": [2, 3],
  "disallow": [1, 2, 3],
  "extends": [1, 2, 3],
  "uniqueItems": [2, 3, 4, 5, 6, 7, 8, 9],
  "multipleOf": [4, 5, 6, 7, 8, 9],
  "minProperties": [4, 5, 6, 7, 8, 9],
  "maxProperties": [4, 5, 6, 7, 8, 9],
  "allOf": [4, 5, 6, 7, 8, 9],
  "anyOf": [4, 5, 6, 7, 8, 9],
  "oneOf": [4, 5, 6, 7, 8, 9],
  "not": [4, 5, 6, 7, 8, 9],
  "const": [6, 7, 8, 9],
  "propertyNames": [6, 7, 8, 9],
  "id": [1, 2, 3, 4, 5],
  "$id": [6, 7, 8, 9],
  "if": [7, 8, 9],
  "then": [7, 8, 9],
  "else": [7, 8, 9],
  "contentMediaType": [7, 8, 9],
  "$comment": [7, 8, 9],
  "readOnly": [7, 8, 9],
  "writeOnly": [7, 8, 9],
  "definitions": [4, 5, 6, 7, 8, 9],  # deprecated 8- (official 9)
  "dependencies": [3, 4, 5, 6, 7, 8, 9],  # deprecated 8- (official 9)
  "$def": [8, 9],
  "deprecated": [8, 9],
  "dependentSchemas": [8, 9],
  "dependentRequired": [8, 9],
  "unevaluatedItems": [8, 9],
  "unevaluatedProperties": [8, 9],
  "$recursiveRef": [8],
  "$recursiveAnchor": [8],
  "$dynamicRef": [9],
  "$dynamicAnchor": [9],
  "propertyDependencies": [10],  # new online draft
}

FORMAT_ALL_VERSIONS = [ "date-time", "uri", "email", "ipv6" ]

# which formats are allowed at each versions
FORMAT_VERSIONS = {
  "date": [1, 2, 3, 7, 8, 9],
  "date-time": [1, 2, 3, 4, 5, 6, 7, 8, 9],
  "time": [1, 2, 3, 7, 8, 9],
  "duration": [8, 9],
  "utc-millisec": [3],
  "regex": [1, 2, 3, 7, 8, 9],
  "color": [1, 2, 3],
  "style": [1, 2, 3],
  "phone": [1, 2, 3],
  "uri": [1, 2, 3, 4, 5, 6, 7, 8, 9],
  "iri": [7, 8, 9], # RFC 3987
  "uri-ref": [5],
  "uri-reference": [6, 7, 8, 9],
  "iri-reference": [7, 8, 9],
  "uuid": [8, 9],  # 9? was it really in 2020-12?
  "uri-template": [6, 7, 8, 9],
  "json-pointer": [6, 7, 8, 9],
  "relative-json-pointer": [7, 8, 9],
  "email": [1, 2, 3, 4, 5, 6, 7, 8, 9],
  "idn-email": [7, 8, 9],
  "ip-address": [1, 2, 3],
  "ipv4": [4, 5, 6, 7, 8, 9],
  "ipv6": [1, 2, 3, 4, 5, 6, 7, 8, 9],
  "host-name": [3],
  "hostname": [4, 5, 6, 7, 8, 9],
  "idn-hostname": [7, 8, 9],
  "street-address": [1, 2],
  "locality": [1, 2],
  "region": [1, 2],
  "country": [1, 2],
  # additional custom formats may be defined with a URL to a definition of the format
  # OpenAPI 3.1:
  # - integer: int32, int64
  # - number: float, double
  # - string: password
}

# add special version numbers
for _, versions in SCHEMA_VERSION_GUESS.items():
    if CURRENT_VERSION in versions:
        versions.append(NEXT_VERSION)
        versions.append(LATEST_VERSION)

for f in FORMAT_ALL_VERSIONS:
    del FORMAT_VERSIONS[f]

for _, versions in FORMAT_VERSIONS.items():
    if CURRENT_VERSION in versions:
        versions.append(NEXT_VERSION)
        versions.append(LATEST_VERSION)

def guess_version(col: dict):
    ALL = { i for i in range(1, LATEST_VERSION+1) }
    valid = set()
    invalid = set()
    keywords = []

    for prop, versions in SCHEMA_VERSION_GUESS.items():
        if prop in col and col[prop] > 0:
            if set(versions).difference(valid) or ALL.difference(versions).difference(invalid):
                keywords.append(prop)
            valid.update(versions)
            invalid.update(ALL.difference(versions))

    # possible versions
    if not valid and not invalid:
        # no clues
        versions = ALL
    else:
        versions = valid.difference(invalid)

    col["<versions>"] = list(sorted(versions))

    if not versions:
        collectErr(col, "incompatible version guesses", f"{keywords}", "$")


# all predefined JSON Schema types for Draft 4 and later
JSON_SCHEMA_TYPES = [ "null", "boolean", "integer", "number", "string", "array", "object" ]

def typeof(v: any) -> str:
    return ("null" if v is None else
            "boolean" if isinstance(v, bool) else
            "integer" if isinstance(v, int) else
            "number" if isinstance(v, float) else
            "string" if isinstance(v, str) else
            "array" if isinstance(v, (list, tuple)) else
            "object" if isinstance(v, dict) else
            "<unknown>")

def collectAdd(collection, key, n):
    if key in collection:
        collection[key] += n
    else:
        collection[key] = n

def collectCnt(collection, key):
    collectAdd(collection, key, 1)

def collectSet(collection, key, val):
    if key not in collection:
        collection[key] = set()
    collection[key].add(val)

def collectErr(collection, cat, what, path):
    collectSet(collection, "<errors>", (cat, what, path))

def collectTypo(collection, what, path):
    collectSet(collection, "<typos-keywords>", what)
    collectSet(collection, "<typos-keywords-where>", (what, path))

def ap(path: str, key: str):
    if re.search(r"^[a-zA-Z0-9_]+$", key):
        return f"{path}.{key}"
    else:
        return f'{path}."{key}"'

#
# TYPE RESOLUTION
#

ALL_TYPES = { "null", "boolean", "integer", "number", "string", "array", "object" }
NO_TYPE = set()

def fixIntNum(types: set[str]):
    """Ensure that integer/number are accepted one for the other."""
    if "integer" in types:
        types.add("number")
    if "number" in types:
        types.add("integer")

# getTypes cache path and context to set of types there
GET_TYPES_CACHE: dict[str, set[str]] = {}

def getTypes(
    jdata: bool|dict[str, any],  # JSON Schema
    defs: dict[str, any],        # current definitions
    recs: list[str],             # paths to detect recursion
    path: str,                   # current path
    context: set[str]            # external context for adjacent keywords
) -> set[str]:
    """Return the possible types for the current schema."""

    # log.warning(f"types on {path} <- {context}")

    if path and path.endswith(".propertyNames"):
        # we know that we are checking a string
        return { "string" }

    if isinstance(jdata, bool):
        return set(ALL_TYPES if jdata else NO_TYPE)

    if not isinstance(jdata, dict):
        # FIXME should not be possible!
        return { "BAD" }

    # cache shortcut
    path_ctx = path + ":" + str(sorted(context))
    if path_ctx in GET_TYPES_CACHE:
        return GET_TYPES_CACHE[path_ctx]

    # set initial possible types
    if "type" in jdata:
        # if there is an explicit type, it constrains the result
        types = jdata["type"]
        if isinstance(types, str):
            if types == "any":  # early versions…
                possible_types = set(ALL_TYPES)
            elif types in ALL_TYPES:
                possible_types = { types }
            else:
                log.warning(f"unexpected string type: {types}")
                # FIXME NO_TYPE?
                possible_types = set(ALL_TYPES)
        elif isinstance(types, (tuple, list)):
            ltypes = set()
            for i, t in enumerate(types):
                if isinstance(t, str):
                    if t == "any":
                        ltypes.update(ALL_TYPES)
                    elif t in ALL_TYPES:
                        ltypes.add(t)
                    else:
                        log.warning(f"coldly ignoring unexpected type: {t}")
                elif isinstance(t, dict):  # early versions
                    ltypes.update(getTypes(t, defs, recs, f"{path}.type[{i}]", ALL_TYPES))
                else:
                    log.warning(f"unexpected type item type: {typeof(t)}")
            possible_types = ltypes
        elif isinstance(types, dict):  # early versions
            possible_types = getTypes(types, defs, recs, path + ".type", ALL_TYPES)
        else:
            log.warning(f"unexpected value for type: {typeof(types)}")
            possible_types = { "BOF" }
    else:
        possible_types = set(ALL_TYPES)
    fixIntNum(possible_types)

    # make current explicit types consistent with context
    possible_types.intersection_update(context)
    fixIntNum(possible_types)

    # then reduce with other type informations
    if "const" in jdata:
        possible_types.intersection_update({ typeof(jdata["const"]) })
        fixIntNum(possible_types)

    if "enum" in jdata and isinstance(jdata["enum"], (tuple, list)):
        possible_types.intersection_update(typeof(i) for i in jdata["enum"])
        fixIntNum(possible_types)

    if "$ref" in jdata:
        rpath = jdata["$ref"]
        if isinstance(rpath, str):
            rpathu = url_unquote(rpath)
            if rpathu in recs:
                log.warning(f"preventing recursion on {rpath}")
                # possible_types is left "as-is"?
            elif rpathu in defs:
                possible_types.intersection_update(getTypes(defs[rpathu], defs, recs + [ rpathu ], rpathu, possible_types))
                fixIntNum(possible_types)
            else:
                log.warning(f"definition not available: {rpath}")
        else:
            log.warning(f"unexpected $ref value type: {typeof(rpath)}")

    if "allOf" in jdata:
        alls = jdata["allOf"]
        atypes = set(ALL_TYPES)
        if isinstance(alls, (tuple, list)):
            for i, a in enumerate(alls):
                atypes.intersection_update(getTypes(a, defs, recs, f"{path}.allOf[{i}]", possible_types))
        else:
            log.warning(f"unexpected allOf type: {typeof(alls)}")
        possible_types.intersection_update(atypes)
        fixIntNum(possible_types)

    for prop in ("anyOf", "oneOf"):
        if prop in jdata:
            anys = jdata[prop]
            atypes = set()
            if isinstance(anys, (tuple, list)):
                for i, a in enumerate(anys):
                    atypes.update(getTypes(a, defs, recs, f"{path}.{prop}[{i}]", possible_types))
            else:
                log.warning(f"unexpected {prop} type: {typeof(anys)}")
            possible_types.intersection_update(atypes)
            fixIntNum(possible_types)

    # FIXME if/then/else/not *could* maybe constraint some types as well

    if path_ctx not in GET_TYPES_CACHE:
        GET_TYPES_CACHE[path_ctx] = possible_types

    # log.warning(f"types on {path} -> {possible_types}")

    return possible_types

#
# COLLECT TYPE HINTS
#

GET_HINTS_CACHE: dict[str, set[str]] = {}

def getHints(
    jdata: bool|dict[str, any],  # JSON data
    defs: dict[str, any],        # current definitions
    recs: list[str],             # paths to detect recursion
    path: str                    # current path
) -> set[str]:
    """Gather hints about types."""

    if isinstance(jdata, bool):
        return NO_TYPE

    if not isinstance(jdata, dict):
        log.warning(f"bad schema type at {path}: {typeof(jdata)}")
        return NO_TYPE

    if path in GET_HINTS_CACHE:
        return GET_HINTS_CACHE[path]

    hints = set()

    # handle direct hints
    for prop in jdata.keys():
        if prop in PROP_TO_TYPE:
            hints.add(PROP_TO_TYPE[prop])

    # format hint depends on the value
    if "format" in jdata:
        fmt = jdata["format"]
        if isinstance(fmt, str):
            if fmt in FORMAT_ALL_VERSIONS or fmt in FORMAT_VERSIONS or fmt == "password":
                hints.add("string")
            elif fmt in ("integer", "int32", "int64", "float", "double", "uint", "uint32", "uint64"):
                hints.add("number")
            else:
                # unknown value, not hint…
                pass

    # update with indirect hints
    if "$ref" in jdata:
        ref = jdata["$ref"]

        if not isinstance(ref, str):
            log.warning(f"ignoring bad $ref value type: {typeof(ref)}")
            return

        refu = url_unquote(ref)
        if refu in recs:
            log.warning(f"preventing recursion for hints on {ref}")
        elif refu in defs:
            hints.update(getHints(defs[refu], defs, recs + [refu], refu))
        else:
            log.warning(f"ignoring $ref hints: {ref}")

    # combinators
    if "allOf" in jdata:
        schemas = jdata["allOf"]
        if isinstance(schemas, (tuple, list)):
            shints = set()
            for i, s in enumerate(schemas):
                shints.update(getHints(s, defs, recs, f"{path}.allOf[{i}]"))
            hints.update(shints)
        else:
            log.warning(f"ignoring bad allOf value type: {typeof(schemas)}")

    for prop in ("anyOf", "oneOf"):
        if prop in jdata:
            schemas = jdata[prop]
            if isinstance(schemas, (tuple, list)):
                shints = set(ALL_TYPES)
                for i, s in enumerate(schemas):
                    shints.intersection_update(getHints(s, defs, recs, f"{path}.{prop}[{i}]"))
                hints.update(shints)
            else:
                log.warning(f"ignoring bad {prop} value type: {typeof(schemas)}")

    # FIXME should it do something with not/if/then/else?
    # FIXME format?

    if path not in GET_HINTS_CACHE:
        GET_HINTS_CACHE[path] = hints
    # else cannot happen? or check consistency?

    return hints


def looks_like_simple_dependencies(data) -> bool:
    """Check whether it is a simple { "": [""] }."""
    if not isinstance(data, dict):
        return False
    for k, v in data.items():
        if not isinstance(k, str) or not isinstance(v, (tuple, list)):
            return False
        for s in v:
            if not isinstance(s, str):
                return False
    return True


class Defs:
    """Keep track of definitions and uses."""

    def __init__(self):
        # is it an official definition?
        self._isdef = re.compile(r"/(\$defs|definitions)/\w+$").search
        self._defs: dict[str, any] = {}
        self._uses: dict[str, int] = {}

    def __setitem__(self, p: str, v):
        if self._isdef(p):
            self._uses[p] = 0
        self._defs[p] = v

    def __contains__(self, p: str):
        return p in self._defs

    def __getitem__(self, p: str):
        if self._isdef(p):
            self._uses[p] += 1
        return self._defs[p]

    def __delitem__(self, p: str):
        del self._defs[p]

    # vs unreachable?
    def unusedDefs(self):
        return { p for p in self._uses.keys() if self._uses[p] == 0 }


# maybe too much, it could collect the root and use the path when needed.
def _collect_all_defs_rec(data, defs, path: str = "#"):
    """Collect all possible local definitions just in case…"""
    if isinstance(data, (bool, dict, list, tuple)):
        defs[path] = data
    if data is None or isinstance(data, (bool, int, float, str)):
        pass
    elif isinstance(data, (list, tuple)):
        for i, item in enumerate(data):
            # TODO check JSON Schema url path stuff
            _collect_all_defs_rec(item, defs, f"{path}/{i}")
    elif isinstance(data, dict):
        for k, v in data.items():
            _collect_all_defs_rec(v, defs, f"{path}/{k}")


def _json_schema_stats_rec(
    jdata: bool|dict,                    # schema
    path: str,                           # path to ~
    collection: dict[str, int],          # collected data
    defs: dict[str, any] = {},           # definitions
    type_context: set[str] = ALL_TYPES,  # type restrictions at this point
    is_defs: bool = False,               # is this just a definition
    is_logic: bool = False               # are we inside a if/then/else/not?
) -> None:
    """Recursive usage stats collection about JSON Schema features."""

    if isinstance(jdata, bool):
        if jdata:
            collection["true"] += 1
        else:
            collection["false"] += 1
        return

    if not isinstance(jdata, dict):
        collectErr(collection, "invalid root schema type", typeof(jdata), path)
        log.warning(f"skipping: [{path}] {str(jdata)[:64]}")
        return

    if len(jdata) == 0:
        collection["{}"] += 1
        return

    # current schema guessing
    if "$schema" in jdata:
        version = jdata["$schema"]
        if isinstance(version, str):
            if  "/json-schema.org/" in version:
                for pat, vers in SCHEMA_VERSIONS.items():
                    if pat in version:
                        cvers = collection["<version>"]
                        if cvers == 0:
                            collection["<version>"] = vers
                            collection["<version-path>"] = path
                        elif cvers > 0 and cvers != vers:
                            collection["<version>"] = -1
                            collectErr(collection, "multiple schema versions", f"{cvers} {vers}", path)
                        break
                if collection["<version>"] == 0:  # not assigned
                    collectErr(collection, f"unexpected $schema", version, path)
            else:
                collectErr(collection, f"unexpected $schema version", version, path)
        else:
            collectErr(collection, f"unexpected $schema value type", typeof(version), path)

    # memoize defs for later
    if "$defs" in jdata and "definitions" in jdata:
        collectErr(collection, "definition issue", "$defs/definitions mix", path)

    kdefs = "$defs" if "$defs" in jdata else "definitions"
    ldefs = jdata[kdefs] if kdefs in jdata else None

    if kdefs in jdata and not isinstance(jdata[kdefs], dict):
        collectErr(collection, "definition issue", f"unexpected type {typeof(ldefs)}", path)

    # get actually possible types
    types = getTypes(jdata, defs, [], path, type_context)

    if not types:
        collectErr(collection, "type error", "no possible type", path)

    # scan all properties
    for prop, val in jdata.items():

        lpath = ap(path, prop)

        # count (expected) prop occurences
        if prop in collection:
            collection[prop] += 1
        else:
            # count typos and unknown and keep track of openapi
            if prop.startswith("x-"):
                collectSet(collection, "<extensions>", prop)
            elif prop in OPENAPI_310_KEYWORDS:
                collectSet(collection, "<openapi>", prop)
            elif prop in SCHEMA_KEYS_TYPOS:
                collection["<typos>"] += 1
                collectTypo(collection, prop, lpath)
            else:
                collection["<unknown>"] += 1
                collectSet(collection, "<unknown-keywords>", prop)
                # this may really
                log.warning(f"unexpected: {prop}")

            # unknow keyword, try subschemas for draft 01-04
            # this may result in false positive, eg for OpenAPI "example"
            if isinstance(val, dict) and prop not in ("example", "discriminator") and not prop.startswith("x-"):
                _json_schema_stats_rec(val, lpath, collection, defs, is_logic=is_logic)

            # FIXME because of extensions any keyword should be ignored,
            # probaby hidding away any typo…

        # recurse in some cases, or specials
        if prop == "type":

            if isinstance(val, (list, tuple)):
                collection["type-list"] += 1
                if len(val) == 0:
                    collection["type-list-empty"] += 1
                elif len(val) == 1:
                    collection["type-list-one"] += 1
                vals = val
            elif isinstance(val, str):
                vals = [val]
            else:
                collectErr(collection, "invalid type value", typeof(val), lpath)
                continue

            nonstr = list(filter(lambda i: not isinstance(i, str), vals))
            if nonstr:
                collectErr(collection, "invalid type value in list", str(nonstr), lpath)
                continue

            for v in vals:
                if isinstance(v, str):
                    pval = f"{prop}={v}"
                    if pval in collection:
                        collection[pval] += 1
                    else:
                        collectErr(collection, "unexpected type data", v, path)
                elif isinstance(v, dict):
                    collectErr(collection, "maybe unexpected type type", str(v), lpath)
                    # try a sub-type object
                    _json_schema_stats_rec(v, lpath, collection, defs, is_logic=is_logic)
                else:
                    collectErr(collection, "unexpected type type", str(v), lpath)

        elif prop == "format":

            # TODO improve format analysis! count all occurrences!?
            if isinstance(val, str):
                if val in OPENAPI_310_FORMATS:
                    collectSet(collection, "<openapi>", val)
                    continue
                elif val not in FORMATS:
                    collectErr(collection, "unexpected format", val, lpath)
                    continue
                # count expected format values
                collectCnt(collection, f"format={val}")
            else:
                collectErr(collection, "invalid format type", typeof(val), lpath)
                log.warning(f"ignoring {prop} value")
                continue

        elif prop == "pattern":

            if not isinstance(val, str):
                collectErr(collection, "invalid pattern type", typeof(val), lpath)
            elif not is_regex(val):
                collectErr(collection, "invalid regex", val, lpath)

        elif prop == "patternProperties":

            if isinstance(val, dict):
                for k, v in val.items():
                    # assert isinstance(k, str)
                    if not is_regex(k):
                        collectErr(collection, "invalid regex", k, lpath)
            else:
                collectErr(collection, "invalid patternProperties type", typeof(val), lpath)

        elif prop in ("dependencies", "properties"):

            if not isinstance(val, dict):
                collectErr(collection, f"non object {prop}", typeof(val), lpath)

        elif prop == "items":

            if isinstance(val, (list, tuple)):
                collection["items-list"] += 1
            if collection["<version>"] >= 9 and isinstance(val, (list, tuple)):
                collectErr(collection, "draft incompatibility", "invalid array value for items after Draft 9", lpath)

        elif (prop == "id" and collection["<version>"] <= 5 and collection["<version>"] != 0 or
              prop == "$id" and collection["<version>"] >= 6):

            if not isinstance(val, str):
                collectErr(collection, f"invalid {prop} value type", typeof(val), lpath)

        elif (prop == "id" and collection["<version>"] >= 6 or
              prop == "$id" and collection["<version>"] <= 5 and collection["<version>"] != 0):

            collectErr(collection, "draft incompatibility", "id/$id draft confusion", lpath)

        elif prop == "$ref":
            # NOTE "#" is used for recursion at the root
            if not isinstance(val, str):
                collectErr(collection, "invalid $ref type", typeof(val), lpath)
            elif val.startswith("#/"):
                valu = url_unquote(val)
                if not valu in defs:
                    collectErr(collection, "dangling $ref value", val, lpath)
            else:
                log.warning(f"ignoring $ref value: {val}")

        elif prop == "default":
            if typeof(val) not in types:
                collectErr(collection, "type inconsistency", f"default {typeof(val)} / {types}", lpath)

        elif prop == "examples":
            if isinstance(val, (list, tuple)):
                for v in val:
                    if typeof(v) not in types:
                        collectErr(collection, "type inconsistency", f"examples {typeof(v)} / {types}", lpath)
            else:
                collectErr(collection, f"invalid {prop} value type", typeof(val), lpath)

        # possible recursions
        if prop in SCHEMA_KEYS_OBJECT_VALUES_SCHEMAS:
            # log.info(f"object {prop}: {val}")
            is_a_defs = prop in ("$defs", "definitions")
            if isinstance(val, dict):
                for k, v in val.items():
                    _json_schema_stats_rec(v, ap(lpath, k), collection, defs, is_defs=is_a_defs, is_logic=is_logic)
                collection[f"{prop}-count"] += len(val)
            else:
                log.warning(f"ignoring {prop} non-object value")

        if prop in SCHEMA_KEYS_ARRAY_OF_SCHEMAS:  # combinators and others
            if isinstance(val, (list, tuple)):
                if len(val) == 0:
                    collectErr(collection, "empty schema array", prop, lpath)
                context = types if prop in ("allOf", "anyOf", "oneOf") else ALL_TYPES
                for i, v in enumerate(val):
                    _json_schema_stats_rec(v, f"{lpath}[{i}]", collection, defs, context, is_logic=is_logic)
            else:
                log.warning(f"ignoring {prop} non-array value")

        if prop in SCHEMA_KEYS_VALUE_SCHEMA:
            if prop == "dependencies" and looks_like_simple_dependencies(val):
                # TODO we should check that properties exists!
                pass
            elif isinstance(val, (bool, dict)):
                _json_schema_stats_rec(val, lpath, collection, defs,
                                       is_logic=is_logic or prop in ("if", "then", "else", "not"))
            else:
                log.warning(f"ignoring {prop} non-schema value")

        if prop in SCHEMA_KEYS_VALUE_SCHEMA and prop in SCHEMA_KEYS_ARRAY_OF_SCHEMAS:
            if not isinstance(val, (bool, dict, list, tuple)):
                collectErr(collection, "unexpected type", f"{prop} / {typeof(val)}", lpath)

        # special case for which we keep a (truncated) value
        if prop in SPECIAL_VALUES:
            key = f"{prop}={str(val)[:64]}"
            if key not in collection:
                collection[key] = 0
            collection[key] += 1

        if prop in INTEGER_KEYWORDS and not isinstance(val, int):
            collectErr(collection, "non integer value", f"{prop} / {typeof(val)}", lpath)

        elif prop in NUMBER_KEYWORDS and not isinstance(val, (int, float)):
            collectErr(collection, "non number value", f"{prop} / {typeof(val)}", lpath)

        # Case additionalProperties in Properties
        if prop == "properties" and isinstance(val, dict):
            # dans val il y a des propriétés PER_TYPE["object"] mais pas la propriété "properties"
            doubts = list(filter(lambda k: k in DOUBTFUL_PROPERTY_NAMES, val.keys()))
            nb_js_prop = len(doubts)
            nb_prop = len(val)
            if nb_js_prop >= 1 and "properties" not in val:
                collectCnt(collection, "<bad-properties-nesting>")
                collectSet(collection, "<bad-properties-nesting-where>", f"{path}: {doubts}")

        elif prop == "additionalProperties" and isinstance(val, bool):
            if val:
                collection["additionalProperties=true"] += 1
            else:
                collection["additionalProperties=false"] += 1

        elif prop == "additionalItems" and isinstance(val, bool):
            if val:
                collection["additionalItems=true"] += 1
            else:
                collection["additionalItems=false"] += 1

        elif prop == "required":
            if collection["<version>"] >= 4 and isinstance(val, bool):
                collectErr(collection, "draft incompatibility", "invalid bool required for Draft 4 and later", lpath)
            elif collection["<version>"] == 3 and isinstance(val, (list, tuple)):
                collectErr(collection, "draft incompatibility", "invalid array required for  Draft 3", lpath)
            elif not isinstance(val, (bool, list, tuple)):
                collectErr(collection, "invalid required type", typeof(val), lpath)

            if isinstance(val, (list, tuple)):
                collection["required-list"] += 1
                collection["required-count"] += len(val)
                if len(val) == 0:
                    collection["required-empty"] += 1
                    if collection["<version>"] == 4:
                        # but is is okay for 6 and later:-/
                        collectErr(collection, "draft incompatibility", "invalid empty required for Draft 4", lpath)
            elif isinstance(val, bool):  # OLD
                collection["required-bool"] += 1
                collection[f"required={str(val).lower()}"] += 1
            else:
                log.warning(f"unexpected required: {val}")
                continue

        elif prop == "enum":
            if isinstance(val, (list, tuple)):
                if len(val) == 0:
                    collectErr(collection, "empty array enum", "", lpath)
                    collection["enum-empty"] += 1
                elif len(val) == 1:
                    collection["enum-one"] += 1
            else:
                collectErr(collection, "non array enum", typeof(val), lpath)

        elif prop in ("exclusiveMinimum", "exclusiveMaximum"):
            if isinstance(val, bool):
                collection[f"{prop}={str(val).lower()}"] += 1

        if prop in SCHEMA_KEYS_ARRAY_OF_SCHEMAS:
            # this silently ignores non lists
            if isinstance(val, (list, tuple)):
                collection[f"{prop}-count"] += len(val)
                if len(val) == 0:
                    collection[f"{prop}-empty"] += 1
                elif len(val) == 1:
                    collection[f"{prop}-one"] += 1

        if prop in ("type", "required", "enum") and isinstance(val, (list, tuple)):
            if not distinct_values(val):
                collectErr(collection, "non unique array", f"{prop} {len(val)}", lpath)


    # FIXME should follow references as well!
    # FIXME should take care of adjacent keywords in the resolution!
    # build type hints based on keywords
    hints = getHints(jdata, defs, [], path)

    # special case for required
    required_list = "required" in jdata and isinstance(jdata["required"], (list, tuple))
    if required_list:
        hints.add(PROP_TO_TYPE["required-list"])
        # TODO resolve references? recurse??
        # NOTE filter out constructs which may bring hidden properties
        if "properties" in jdata and not set(jdata.keys()).intersection({"oneOf", "anyOf", "$ref"}):
            required = jdata["required"]
            properties = jdata["properties"]
            for p in required:
                if p not in properties:
                    collectErr(collection, "unknown required property", p, path)
        # else: maybe properties are in a reference…

    # check whether found types are compatible with declared types
    for m in hints:
        # a type hint is not compatible with possible types
        if m in JSON_SCHEMA_TYPES and m not in types:
            if m == "number" and "integer" in types:
                # ok, integer is a kind of number
                pass
            else:
                # extract direct keywords which hinted to type "m"
                keywords = set(filter(lambda p: PROP_TO_TYPE.get(p, "") == m, jdata.keys()))
                if required_list:
                    keywords.add('required')
                # actual types found
                # FIXME probably useless
                foundtypes = set(filter(lambda t: t in JSON_SCHEMA_TYPES, types))
                if not foundtypes:
                    foundtypes = set(types)
                collectErr(collection, "bad mix", f"{m}: {sorted(foundtypes)} {sorted(keywords)}", path)

    # no type declarations *BUT* some type hints
    # NOTE *direct* definitions are skipped, should be triggered when/if used
    # TODO <= 2? other?
    if len(types) == 7:
        type_hints = hints.difference({"meta", "combi", "hyper", "alone"})
        if not is_defs and not is_logic and len(type_hints) == 1:
                collectErr(collection, "missing type declaration", f"{type_hints}", path)
        elif len(type_hints) == 0 and len(path) > 1:
            collectErr(collection, "suspicious empty type", "*", path)

    # log.debug(f"mixins: {mixins}")
    mix = "*-" + "-".join(sorted(types)) + "/" + "-".join(sorted(hints))

    if mix != "*-/":
        if mix in collection:
            collection[mix] += 1
        else:
            collection[mix] = 1

def json_schema_stats(jdata):
    """Return stats about a JSON data structure."""

    global GET_TYPES_CACHE, GET_HINTS_CACHE
    GET_TYPES_CACHE.clear()
    GET_HINTS_CACHE.clear()

    # we first collect all possible local definitions, just in case
    defs = Defs()
    _collect_all_defs_rec(jdata, defs)

    # then proceed to analyze the schema
    collection = { k: 0 for k in SCHEMA_KEYS }
    _json_schema_stats_rec(jdata, "$", collection, defs)

    # unused definitions
    collection["<unused-defs>"] = list(sorted(defs.unusedDefs()))

    # do version guessing on the result
    guess_version(collection)

    # official $schema at root?
    if isinstance(jdata, dict) and "$schema" in jdata:
        if "/json-schema.org/" in jdata["$schema"]:
            collection["<explicit-schema>"] = True
        else:
            collection["<explicit-schema>"] = False
        collection["<$schema>"] = jdata["$schema"]
    else:
        collection["<explicit-schema>"] = False
        collection["<$schema>"] = "<unknown_explicit_schema>"

    # is the root type compatible with a JSON schema?
    collection["<bad-root>"] = not isinstance(jdata, (bool, dict))

    # look for schema property name hints
    collection["<schema-prop>"] = False
    if isinstance(jdata, dict):
        for prop in jdata.keys():
            if prop in PROP_TO_TYPE and PROP_TO_TYPE[prop] in ["alone","number", "string","array","object","combi"]:
                collection["<schema-prop>"] = True
                break

    # cleanup sets
    for key in SETS:
        if key in collection:
            collection[key] = list(sorted(collection[key]))

    return collection

def normalize_ods(fn, schema):
    if not isinstance(schema, dict) or len(schema) != 4:
        return
    if "title" not in schema or "definitions" not in schema or "oneOf" not in schema or "type" not in schema:
        return
    if schema["type"] != "object":
        return

    title = schema["title"]
    oneof = schema["oneOf"]

    if len(oneof) != 1 or len(oneof[0]) != 1 or "$ref" not in oneof[0] and oneof[0]["$ref"] != f"#/definitions/{title}":
        return

    rec =  f"{title}_records"
    defs = schema["definitions"]
    if title not in defs or rec not in defs or len(defs) != 2:
        return

    log.warning(f"Anonymizing {fn}")
    schema["title"] = "ANONYM"
    oneof[0]["$ref"] = "#/definitions/ANONYM"
    defs["ANONYM"] = defs[title]
    del defs[title]
    defs["ANONYM_records"] = defs[rec]
    del defs[rec]
    defs["ANONYM"]["properties"]["records"]["items"]["$ref"] = "#/definitions/ANONYM_records"

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
