<template>
  <q-layout view="lHh Lpr lFf">
    <q-tabs
      v-model="tab"
      active-bg-color="primary"
      bg-color="primary"
      text-color="positive"
      class="q-my-md shadow-2"
      inline-label>
      <q-tab name="H2L" icon="bolt" label="Get Lightning" />
      <q-tab name="L2H" icon="hexagon" label="Get Hive" />
    </q-tabs>
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>
<script>

export default {
  name: 'MainLayout',
  data () {
    return {
      tab: 'H2L'
    }
  }
}
</script>
