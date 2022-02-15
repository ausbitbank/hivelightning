<template>
  <q-page class="flex flex-center">
    <q-card flat class="text-center q-pa-md">
      <q-tabs
        v-model="tab"
        dense
        class="text-grey"
        active-color="primary"
        indicator-color="primary"
        align="justify"
        narrow-indicator
      >
        <q-tab name="h2l" icon="bolt" label="Get Lightning" />
        <q-tab name="l2h" icon="bolt" label="Get Hive" />
        <q-tab name="info" icon="info" label="Info" />
      </q-tabs>

      <q-separator />

      <q-tab-panels v-model="tab" animated>
        <q-tab-panel name="h2l">
          <hivelight
            v-bind:prices="prices"></hivelight>
        </q-tab-panel>

        <q-tab-panel name="l2h">
          <div class="text-h6">Lightning to Hive</div>
          <lighthive
          v-bind:prices="prices"></lighthive>
        </q-tab-panel>

        <q-tab-panel name="info">
          <div class="text-h6">Info</div>
          Lorem ipsum dolor sit amet consectetur adipisicing elit.
        </q-tab-panel>
      </q-tab-panels>
    </q-card>
  </q-page>
</template>

<style scoped>
</style>

<script>
import HiveToLightningVue from 'src/components/HiveToLightning.vue'
import LightningToHiveVue from 'src/components/LightningToHive.vue'

export default {
  name: 'PageIndex',
  data () {
    return {
      tab: 'l2h'
    }
  },
  props: ['prices'],
  computed: {
  },
  components: {
    hivelight: HiveToLightningVue,
    lighthive: LightningToHiveVue
  },
  mounted () {
  }
}
</script>
