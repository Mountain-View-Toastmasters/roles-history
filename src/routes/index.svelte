<script lang="ts">
  import { onMount } from "svelte";
  import MeetingView from "$lib/MeetingView.svelte";

  let rolesData: any[] = [];
  onMount(async () => {
    let resp = await fetch("/data.json");
    rolesData = await resp.json();
  });
</script>

<h1>toastmasters</h1>

<MeetingView {rolesData} />
