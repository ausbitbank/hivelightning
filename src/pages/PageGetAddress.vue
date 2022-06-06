<template>
  <q-page class="flex flex-center">
    <getAddress
      v-bind:prices="prices"
      :sendHiveTo="sendHiveTo"
      :serviceStatus="serviceStatus"
      ></getAddress>
  </q-page>
</template>
<style scoped>
</style>

<script>
import GetAddressVue from 'src/components/GetAddress.vue'

export default {
  name: 'PageGetAddress',
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  computed: {},
  mounted () {
  },
  components: {
    getAddress: GetAddressVue
  }
}
</script>
