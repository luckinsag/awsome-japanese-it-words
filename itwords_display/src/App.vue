<template>
  <v-app>
    <keep-alive>
      <router-view v-if="$route.meta.keepAlive" />
    </keep-alive>
    <router-view v-if="!$route.meta.keepAlive" />
  </v-app>
</template>

<script>
export default {
  name: 'App'
}
</script> 