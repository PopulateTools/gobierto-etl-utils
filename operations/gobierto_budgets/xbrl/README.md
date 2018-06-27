# XBRL

Scripts to load XBRL budget information into Gobierto. [XBRL](https://es.wikipedia.org/wiki/XBRL) is
a XML format to exchange budget information between local governments and the Spanish Fiscal
government.

There are two formats:

- `TRIMLOC`: only contains economic budget lines, and should be used just to inform about the
  execution

- `PENLOC`: contains economic and functional (program) budget lines, and is used to inform about the
  initial budget

## How it works

There are scripts to import from the two formats. Each format requires a dictionary to map the
budget line category name to the numerical ID we use in Gobierto (which is the official ID).

With this dictionary and the XBRL file, the script should be called as a Gobierto runner.

## How to create a dictionary

In `aux/` folder there are a couple of scripts to create the `TRIMLOC` and the `PENLOC` dictionaries. It
basically maps the budget line category name with the name in the file. Some manual proccess is
needed to match some categories.

## TRIMLOC scripts

Although `TRIMLOC` should be used just to inform about the execution, we have implemented scripts to
load budgets, budgets updated and execution.

- `trimloc/transform-planned/run.rb`: imports budget information
- `trimloc/transform-execution/run.rb`: imports execution information
- `trimloc/transform-planned-updated/run.rb`: imports planned updated information

### Call a script

Scripts are transformation scripts that should use later the importer scripts.

Example:

```bash
$DEV_DIR/gobierto-etl-utils/gobierto_budgets/xbrl/transform-execution/run.rb \
$DEV_DIR/gobierto-etl-utils/gobierto_budgets/xbrl/dictionaries/xbrl_trimloc_dictionary.yml \
data.xbrl \
28079 \
2018 \
/tmp/madrid/output-execution-2018.json
```

After that, use `$DEV_DIR/gobierto-etl-utils/gobierto_budgets/import-execution-budgets/run.rb` to load
the data from `/tmp/madrid/output-execution-2018.json`

## PENLOC scripts

__TODO__: this script is still pending to be migrated to a tranformation

`PENLOC` format is used to report about budgeted information. There's just a single script that loads:

- functional budget lines planning
- economic budget lines planning
- economic budget lines that componse the functional budget lines

### Call the script

The arguments are:

- `bin/rails runner`
- `script name`
- `XBRL PENLOC dictionary file`
- `XBRL data file`
- `Gobierto site domain`
- `Year`

```bash
bin/rails runner /var/www/populate-data-indicators/private_data/gobierto/xbrl/penloc/import_budget_lines_budgeted.rb \
/var/www/populate-data-indicators/private_data/gobierto/xbrl/penloc/xbrl_penloc_dictionary.yml \
/var/www/populate-data-indicators/data_sources/private/gobierto/getafe/budgets/28065AA000-Penloc-2018.xbrl \
getafe.gobify.net \
2018
```
