<script lang="ts">
  import { groupBy, sortBy, uniq, get } from "lodash-es";
  export let rolesData: any[] = [];
  const roles = [
    "meeting_theme",
    "toastmaster",
    "jokemaster",
    "general_evaluator",
    "recorder",
    "timer",
    "ah_counter",
    "wordmaster_grammarian",
    "table_topics_master",
    "speaker_1",
    "speaker_2",
    "speaker_3",
    "evaluator_1",
    "evaluator_2",
    "evaluator_3",
  ];
  $: tableData = convertToTable(rolesData);

  // This logic is woefully complicated just to make a transposed table
  function getByDate(obj, dates) {}

  function convertToTable(rolesData: Array<any>) {
    // each row contains a list of people who took on a role for a date
    let table = [];
    let byRole = groupBy(rolesData, "role");
    let dates = sortBy(uniq(rolesData.map((r: any) => r.meeting_date)));
    for (let role of roles) {
      if (role == "meeting_theme") {
        continue;
      }
      let row = [role];
      let byMeeting = groupBy(byRole[role], "meeting_date");
      console.log(byMeeting);
      for (let date of dates) {
        let entries = get(byMeeting, date, []);
        if (entries.length == 0) {
          row.push("");
          continue;
        }
        row.push(entries[0].name);
      }
      table.push(row);
    }
    return table;
  }
</script>

{JSON.stringify(tableData, null, 2)}
