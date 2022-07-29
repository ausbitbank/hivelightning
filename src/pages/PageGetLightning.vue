<template>
  <q-page class="flex flex-center">
    <getlightning
      v-bind:prices="prices"
      :sendHiveTo="sendHiveTo"
      :serviceStatus="serviceStatus"
      ></getlightning>
  </q-page>
</template>
<style scoped>
</style>

<script>
import GetLightningVue from 'src/components/GetLightning.vue'

export default {
  name: 'PageGetLightning',
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  computed: {},
  mounted () {
  },
  components: {
    getlightning: GetLightningVue
  }
}
</script>
