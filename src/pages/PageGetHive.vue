<template>
  <q-page class="flex flex-center">
    <gethive
      v-bind:prices="prices"
      :sendHiveTo="sendHiveTo"
      :serviceStatus="serviceStatus"
    ></gethive>
  </q-page>
</template>
<style scoped>
</style>

<script>
import GetHiveVue from 'src/components/GetHive.vue'

export default {
  name: 'PageGetHive',
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  computed: {},
  mounted () {
  },
  components: {
    gethive: GetHiveVue
  }
}
</script>
