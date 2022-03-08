<template>
  <q-page class="flex flex-center">
    <gethive v-bind:prices="prices"></gethive>
  </q-page>
</template>
<style scoped>
</style>

<script>
import GetLightningVue from 'src/components/GetLightning.vue'

export default {
  name: 'PageGetLightning',
  props: ['prices'],
  computed: {},
  mounted () {
  },
  components: {
    gethive: GetLightningVue
  }
}
</script>
