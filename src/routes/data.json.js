// create a GET route
import { BigQuery } from "@google-cloud/bigquery";

// https://github.com/googleapis/nodejs-bigquery/blob/main/samples/extractTableJSON.js
// https://github.com/googleapis/nodejs-bigquery/blob/main/samples/query.js

const bigquery = new BigQuery({ projectId: "mountain-view-toastmasters" });

export async function GET() {
  const query = `
    SELECT *
    FROM \`mountain-view-toastmasters.mvtm.roles_with_category\`
    WHERE meeting_date > date_sub(current_date(), INTERVAL 12 week)
  `;
  console.log(query);

  const [job] = await bigquery.createQueryJob({
    query: query,
    location: "US",
  });
  console.log(`Job ${job.id} started.`);
  const [rows] = await job.getQueryResults();
  return {
    status: 200,
    headers: {
      "access-control-allow-origin": "*",
    },
    body: rows,
  };
}
