# Gobierto ETL utils

Utilities for ETL scripts for Gobierto

## Setup

Edit `.env.example` and copy it to `.env` or `.rbenv-vars` with the expected values.

This gem relies heavily in [gobierto_data](https://github.com/PopulateTools/gobierto_data)

## Available operations

### Common

#### Download

Downloads a file from an external URL

Usage:

`/path/to/project/operations/download/run.rb "https://input.json" /tmp/output.json`

Output:

- File with the content of input URL

#### Download S3

Downloads the files from S3 folder

Usage:

`/path/to/project/operations/download-s3/run.rb "dir1/dir2" /tmp/output_folder`

Output:

- Files in the output folder

#### Check-json

Checks if a JSON file is valid JSON

Usage:

`/path/to/project/operations/check-json/run.rb /tmp/input.json`

Output:

- Returns exit code 0 if valid file
- Returns exit -1 if invalid file

#### Check-csv

Checks if a CSV file is valid CSV

Usage:

`/path/to/project/operations/check-csv/run.rb /tmp/input.csv`

Output:

- Returns exit code 0 if valid file
- Returns exit -1 if invalid file

#### Convert to UTF-8

Converts a file into UTF-8. By default it expects the encoding to be ISO-8859-1

Usage:

`/path/to/project/operations/convert-to-utf8/run.rb input_file.json output_file.json

Output:

- The input file in UTF-8 encoding

### GobiertoBudgets

#### Annual data

Calculates the CSV and JSON files for the open data section of the given sites with the organization ID provided.

This operation is a Gobierto runner.

Usage:

`/path/to/gobierto bin runner /path/to/project/operations/gobierto_budgets/annual_data/run.rb "2011 2012" organization_ids.txt`

Where:

- `list of years` is a list of years
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- Files are generated in Gobierto

#### Bubbles

Calculates the bubbles JSON file for a set of organization IDs.

Usage:

`/path/to/project/operations/gobierto_budgets/bubles/run.rb organization_ids.txt`

Where:

- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- JSON files with bubbles required data uploaded to S3.

#### Clear budgets

Clear all the budgets data from an organization

Usage:

`/path/to/project/operations/gobierto_budgets/clear-budgets/run.rb organization_ids.txt`

Where:

- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- No output is expected. Data is removed from Elasticsearch

#### Delete total budgets

Deletes total budgets data for a given set of years and a list of organizations.

Usage:

`/path/to/project/operations/gobierto_budgets/delete_total_budget/run.rb "2010 2012" organization_ids.txt`

Where:

- `<years list>` is a list of years separated by a space
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- No output is expected. Data is removed from Elasticsearch

#### Calculate total budget

Calculates total budgets data for a given set of years and a list of organizations.

Usage:

`/path/to/project/operations/gobierto_budgets/update_total_budget/run.rb "2010 2012" organization_ids.txt`

Where:

- `<years list>` is a list of years separated by a space
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- No output is expected. Data is created/updated in Elasticsearch

#### Clear previous providers

Deletes from Populate Data the providers of an organization / location

Usage:

`/path/to/project/operations/gobierto_budgets/clear-previous-providers/run.rb 8019

Where:

- `8019` is the provider ID

Output:

- No output is expected. Data is removed from Elasticsearch

#### Import planned budgets

Imports planned budgets from JSON file

Usage:

`/path/to/project/operations/gobierto_budgets/import-planned-budgets/run.rb input.json <year>

Where:

- `input.json` is a JSON file with budgets data
- `<year>` is the year of the data

Output:

- No output is expected. Data is created/updated in Elasticsearch

#### Import planned budgets updated

Imports planned budgets updated from JSON file

Usage:

`/path/to/project/operations/gobierto_budgets/import-planned-budgets-updated/run.rb input.json <year>

Where:

- `input.json` is a JSON file with budgets data
- `<year>` is the year of the data

Output:

- No output is expected. Data is created/updated in Elasticsearch

#### Import executed budgets

Imports executed budgets from JSON file

Usage:

`/path/to/project/operations/gobierto_budgets/import-executed-budgets/run.rb input.json <year>

Where:

- `input.json` is a JSON file with budgets data
- `<year>` is the year of the data

Output:

- No output is expected. Data is created/updated in Elasticsearch

### Gobierto

#### Publish activity

Publishes an activity in the sites configured with the organization ID.

This operation is a Gobierto runner.

Usage:

`/path/to/gobierto bin runner /path/to/project/operations/gobierto/publish-activity/run.rb budgets_updated organization_ids.txt`

Where:

- `budgets_updated` is a valid Activity from Gobierto
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- Activity is published in Gobierto

#### Clear cache

Clears rails cache.

This operation is a Gobierto runner.

Usage:

`/path/to/gobierto bin runner /path/to/project/operations/gobierto/clear-cache/run.rb`

Output:

- Cache is cleared


