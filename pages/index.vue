<script setup lang="ts">
const { data } = await useFetch('/api/events')
</script>

<template>
  <div>
    Hivecom website like it's 1999
    <br>
    {{ data }}

    <NuxtLink to="/login">
      Login
    </NuxtLink>
  </div>
</template>
