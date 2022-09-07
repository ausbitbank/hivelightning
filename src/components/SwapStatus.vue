<template>
  <div class="text-title text-center">
    <i class="pi pi-hiveio"></i>
    Using swap site run by <b>@{{ sendHiveTo }}</b>
    <div q-pa-sm v-if="serviceStatus" class="text-caption">Exchange Status:
      <span v-if="swapStatus === false"><q-icon name="circle" color="green" title="Exchange Online" /> Online</span>
      <span v-else-if="swapStatus === true"><q-icon name="circle" color="red" title="Exchange Offline for maintenance" /> Offline for maintenance</span>
      <q-btn icon="info" color="blue" flat dense size="sm" title="Show full exchange settings">
        <q-popup-proxy>
          <q-card flat class="text-center q-pa-sm">
            <div class="text-title text-bold">Exchange Settings for {{ sendHiveTo }}</div>
            <div v-for="line in Object.keys(serviceStatus)" :key="line">
              <span v-if="line === 'dynamic_fees_url'">{{ line}} : <a :href="getHiveLink(serviceStatus[line])" target="_blank">{{ serviceStatus[line] }}</a></span>
              <span v-else>{{ line}} : {{ serviceStatus[line] }}</span>
            </div>
          </q-card>
        </q-popup-proxy>
      </q-btn>
      <div v-if="serviceStatus && serviceStatus['dynamic_fees_url']"><a :href="getHiveLink(serviceStatus['dynamic_fees_url'])" target="_blank"><q-icon name="open_in_new" /> Fee Details</a></div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'SwapStatus',
  props: ['sendHiveTo', 'serviceStatus', 'swapStatus'],
  methods: {
    getHiveLink (authperm) { return 'https://hivel.ink/' + authperm }
  }
}
</script>
