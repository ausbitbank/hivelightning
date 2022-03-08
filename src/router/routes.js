
const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '/', component: () => import('pages/PageGetLightning.vue') },
      { path: '/lnd', component: () => import('pages/PageGetLightning.vue') },
      { path: '/hive', component: () => import('pages/PageGetHive.vue') },
      { path: '/info', component: () => import('pages/PageInfo.vue') }
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '*',
    component: () => import('pages/Error404.vue')
  }
]

export default routes
