import gzip
import json
from datetime import date, datetime

from google.cloud import bigquery, storage
import google.auth


def default_serializer(obj):
    """JSON serializer for objects that cannot be serialized by default json code
    https://stackoverflow.com/a/22238613
    """
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} cannot be serialized")


def dump_to_gcs(bucket, name, query, project_id="mountain-view-toastmasters"):
    """Upload data to a gcs bucket in a compressed format."""
    credentials, _ = google.auth.default(
        scopes=[
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/drive",
            "https://www.googleapis.com/auth/bigquery",
        ],
    )

    bq = bigquery.Client(project=project_id, credentials=credentials)
    gcs = storage.Client(project=project_id)
    bucket = gcs.bucket(bucket)
    blob = bucket.blob(
        f"v1/query/{name}.json",
    )
    blob.content_encoding = "gzip"
    # always serve compressed content
    blob.cache_control = "no-cache,no-transform"
    job = bq.query(query)
    print(f"running query {job.job_id} for {name}: {query}")
    output = [dict(row) for row in job]
    # https://cloud.google.com/storage/docs/transcoding#decompressive_transcoding
    blob.upload_from_string(
        gzip.compress(json.dumps(output, default=default_serializer).encode()),
        content_type="application/json",
    )
    print(f"uploaded {name} to {blob.public_url}")


def main(request):
    dump_to_gcs(
        "mountain-view-toastmasters",
        "roles_with_category",
        """
            SELECT *
            FROM mvtm.roles_with_category
            WHERE meeting_date > date_sub(current_date(), INTERVAL 12 week)
        """,
    )


if __name__ == "__main__":
    main(None)
