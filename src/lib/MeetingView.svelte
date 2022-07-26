<script lang="ts">
  import { groupBy, sortBy, uniq, get } from "lodash-es";
  export let rolesData: any[] = [];

  // also include meeting_theme, but separately from roles
  const roles = [
    "toastmaster",
    "tech_chair",
    "zoom_master",
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
  $: byMeetingDate = groupBy(rolesData, "meeting_date");

  let currentName: string | null = null;
  // https://stackoverflow.com/questions/16918094/html-table-with-vertical-rows
  // https://stackoverflow.com/questions/26972529/is-there-a-html-character-that-is-blank-including-no-whitespace-on-all-browser
</script>

<table>
  <tr>
    <th>meeting date</th>
    <th>meeting theme</th>
    {#each roles as role}
      <th>{role.replace("_", " ")}</th>
    {/each}
  </tr>
  {#each sortBy(Object.keys(byMeetingDate)) as meetingDate}
    {@const meetingDateRow = byMeetingDate[meetingDate]}
    {@const byRole = groupBy(meetingDateRow, "role")}
    <tr>
      <td>{meetingDateRow[0].meeting_date}</td>
      <td>{meetingDateRow[0].meeting_theme}</td>
      {#each roles as role}
        {#if role in byRole}
          {@const name = byRole[role][0].name}
          <td
            on:mouseenter={() => (currentName = name)}
            on:mouseleave={() => (currentName = null)}
            style={currentName == name ? "background-color: green" : null}
            >{byRole[role][0].name}</td
          >
        {:else}
          <td><span>&#8203;</span></td>
        {/if}
      {/each}
    </tr>
  {/each}
</table>

<style>
  tr {
    display: block;
    float: left;
  }
  th,
  td {
    display: block;
    border: 1px solid;
  }
</style>
