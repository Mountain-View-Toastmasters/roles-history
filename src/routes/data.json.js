// create a GET route
import fs from "fs";
import path from "path";

export async function GET() {
  let data = fs.readFileSync(path.resolve("data/test.json"), "utf8");
  return {
    status: 200,
    headers: {
      "access-control-allow-origin": "*",
    },
    body: JSON.parse(data),
  };
}
