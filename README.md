# JSON Schema Statistics

This directory contains Shell, Python and SQL scripts used by:

An Analysis of Defects in Public JSON Schemas
Claire Yannou-Medrala, Fabien Coelho
Tech. Report A/794/CRI, Mines Paris - PSL.

## Installation

```shell
# clone corpus and tools
git clone https://github.com/clairey-zx81/yac.git YAC
cd YAC
git submodule update --init
cd ..
git clone https://github.com/clairey-zx81/json-model.git json-model
git clone https://github.com/clairey-zx81/json-schema-stats.git stats
# create python3 venv
python -m venv venv
source venv/bin/activate
pip install -U pip
# pip install git+https://github.com/clairey-zx81/json-model.git
pip install file:./json-model
pip install matplotlib
```

## Compute Stats

```shell
cd stats
# createdb and psql must work
make load.out
make png
```
