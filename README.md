# Gobierto ETL utils

Utilities for ETL scripts for Gobierto

## Setup

Edit `.env.example` and copy it to `.env` or `.rbenv-vars` with the expected values.

This gem relies heavily in [gobierto_data](https://github.com/PopulateTools/gobierto_data)

## Available operations

### common/download

Downloads a file from an external URL

Usage:

`ruby gobierto-etl-utils/operations/download/run.rb "https://input.json" /tmp/output.json`

Output:

- File with the content of input URL

### commond/download S3

Downloads the files from S3 folder

Usage:

`ruby gobierto-etl-utils/operations/download-s3/run.rb "dir1/dir2" /tmp/output_folder`

Output:

- Files in the output folder

### common/upload S3

Uploads a file to S3 gobierto-data bucket

Usage:

`ruby gobierto-etl-utils/operations/upload-s3/run.rb /tmp/foo/execution_status.yml gobierto-etl-gencat/status/last_execution.yml`

Output:

- Path to the uploaded file

### common/check-json

Checks if a JSON file is valid JSON

Usage:

`ruby gobierto-etl-utils/operations/check-json/run.rb /tmp/input.json`

Output:

- Returns exit code 0 if valid file
- Returns exit -1 if invalid file

### common/check-csv

Checks if a CSV file is valid CSV

Usage:

`ruby gobierto-etl-utils/operations/check-csv/run.rb /tmp/input.csv`

Output:

- Returns exit code 0 if valid file
- Returns exit -1 if invalid file

### common/convert to UTF-8

Converts a file into UTF-8. By default it expects the encoding to be ISO-8859-1

Usage:

`ruby gobierto-etl-utils/operations/convert-to-utf8/run.rb input_file.json output_file.json

Output:

- The input file in UTF-8 encoding

### common/prepare working directory

Prepares a directory to be used during the ETL. Removes it and creates it.

Usage:

`ruby gobierto-etl-utils/operations/prepare-working-directory/run.rb /tmp/foo

### gobierto-budgets/annual data

Calculates the CSV and JSON files for the open data section of the given sites with the organization ID provided.

This operation is a Gobierto runner.

Usage:

`/path/to/gobierto bin runner ruby gobierto-etl-utils/operations/gobierto_budgets/annual_data/run.rb "2011 2012" organization_ids.txt`

Where:

- `list of years` is a list of years
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- Files are generated in Gobierto

### gobierto-budgets/bubbles

Calculates the bubbles JSON file for a set of organization IDs.

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/bubles/run.rb organization_ids.txt`

Where:

- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- JSON files with bubbles required data uploaded to S3.

### gobierto-budgets/clear budgets

Clear all the budgets data from an organization

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/clear-budgets/run.rb organization_ids.txt`

Where:

- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- No output is expected. Data is removed from Elasticsearch

### gobierto-budgets/delete total budgets

Deletes total budgets data for a given set of years and a list of organizations.

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/delete_total_budget/run.rb "2010 2012" organization_ids.txt`

Where:

- `<years list>` is a list of years separated by a space
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- No output is expected. Data is removed from Elasticsearch

### gobierto-budgets/calculate total budget

Calculates total budgets data for a given set of years and a list of organizations.

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/update_total_budget/run.rb "2010 2012" organization_ids.txt`

Where:

- `<years list>` is a list of years separated by a space
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- No output is expected. Data is created/updated in Elasticsearch

### gobierto-budgets/clear previous providers

Deletes from Populate Data the providers of an organization / location

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/clear-previous-providers/run.rb 8019

Where:

- `8019` is the provider ID

Output:

- No output is expected. Data is removed from Elasticsearch

### gobierto-budgets/import planned budgets

Imports planned budgets from JSON file

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/import-planned-budgets/run.rb input.json <year>

Where:

- `input.json` is a JSON file with budgets data
- `<year>` is the year of the data

Output:

- No output is expected. Data is created/updated in Elasticsearch

### gobierto-budgets/import planned budgets updated

Imports planned budgets updated from JSON file

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/import-planned-budgets-updated/run.rb input.json <year>

Where:

- `input.json` is a JSON file with budgets data
- `<year>` is the year of the data

Output:

- No output is expected. Data is created/updated in Elasticsearch

### gobierto-budgets/mport executed budgets

Imports executed budgets from JSON file

Usage:

`ruby gobierto-etl-utils/operations/gobierto_budgets/import-executed-budgets/run.rb input.json <year>

Where:

- `input.json` is a JSON file with budgets data
- `<year>` is the year of the data

Output:

- No output is expected. Data is created/updated in Elasticsearch

### gobierto/publish activity

Publishes an activity in the sites configured with the organization ID.

This operation is a Gobierto runner.

Usage:

`/path/to/gobierto bin runner ruby gobierto-etl-utils/operations/gobierto/publish-activity/run.rb budgets_updated organization_ids.txt`

Where:

- `budgets_updated` is a valid Activity from Gobierto
- `organization_ids.txt` is a plain text file with an organization ID per row

Output:

- Activity is published in Gobierto

### gobierto/clear cache

Clears rails cache.

This operation is a Gobierto runner.

Usage:

`/path/to/gobierto bin runner ruby gobierto-etl-utils/operations/gobierto/clear-cache/run.rb`

Output:

- Cache is cleared

### gobierto-data/upload dataset

Uploads (creates or updates) a dataset in Gobierto data

Usage:

```
ruby $DEV_DIR/gobierto-etl-utils/operations/gobierto_data/upload-dataset/run.rb [options]

       (*) all parameters are required except those with default value
        --api-token API_TOKEN        Gobierto Data API Token
        --gobierto-url GOBIERTO_URL  Gobierto Data URL (protocol + host, i.e http://datos.gobierto.es/
        --name DATASET_NAME          Dataset name
        --slug DATASET_SLUG          Dataset slug
        --table-name TABLE_NAME      Dataset table-name
        --file-path FILE_PATH        Data file path
        --append APPEND              Append existing dataset (true or false). By default false
        --visibility-level VISIBILITY_LEVEL
                                     Dataset visibility level (draft or active). By default active
        --csv-separator SEPARATOR    CSV separator. By default ','
    -d, --debug                      Run with debug mode enabled
    -h, --help                       Prints this help
```

Output:

The command responds with a debug log with the HTTP responses
