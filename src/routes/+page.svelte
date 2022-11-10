<script lang="ts">
  import { onMount } from "svelte";
  import MeetingView from "$lib/MeetingView.svelte";

  let rolesData: any[] = [];
  onMount(async () => {
    let resp = await fetch(
      "https://storage.googleapis.com/mountain-view-toastmasters/v1/query/roles_with_category.json"
    );
    rolesData = await resp.json();
  });
</script>

<h1>Mountain View Toastmasters</h1>

<MeetingView {rolesData} />
