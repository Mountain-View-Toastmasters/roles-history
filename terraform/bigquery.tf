// https://gist.github.com/acmiyaguchi/2c7d8698330eef1976590ada5bd71e84
resource "google_bigquery_table" "roles" {
  dataset_id = google_bigquery_dataset.mvtm.dataset_id
  table_id   = "roles"

  // init: bq show --format=json acmiyaguchi:mvtm.roles | jq '.schema' | pbcopy
  schema = jsonencode(jsondecode(file("${path.module}/bigquery/roles.schema.json")).fields)

  external_data_configuration {
    autodetect    = false
    source_format = "GOOGLE_SHEETS"

    google_sheets_options {
      skip_leading_rows = 1
      range             = "Roles"
    }
    source_uris = [
      "https://docs.google.com/spreadsheets/d/1edC7fSgwzDEALY_RZa3rnV80KVpoGGr9WCb6chnjxnE"
    ]
  }
}

resource "google_bigquery_routine" "transpose" {
  dataset_id   = google_bigquery_dataset.mvtm.dataset_id
  routine_id   = "transpose"
  routine_type = "SCALAR_FUNCTION"
  language     = "JAVASCRIPT"
  arguments {
    name      = "datum"
    data_type = jsonencode({ typeKind = "STRING" })
  }
  // This is a bit more verbose than I'd like it to be
  // ARRAY<STRUCT<role STRING, name STRING>> 
  return_type     = <<EOF
    {
        "typeKind": "ARRAY",
        "arrayElementType": {
            "typeKind": "STRUCT",
            "structType": {
                "fields": [
                    {
                        "name": "role",
                        "type": {"typeKind": "STRING"}
                    },
                    {
                        "name": "name",
                        "type": {"typeKind": "STRING"}
                    }
                ]
            }
        }
    }
  EOF
  definition_body = "return Object.entries(JSON.parse(datum)).map(([key, value]) => ({role: key, name: value}))"
}

resource "google_bigquery_table" "roles_with_category" {
  dataset_id = google_bigquery_dataset.mvtm.dataset_id
  table_id   = "roles_with_category"
  view {
    query          = file("${path.module}/bigquery/roles_with_category.view.sql")
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_routine.transpose]
}
