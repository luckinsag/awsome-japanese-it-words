<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const navigateTo = (path) => {
  router.push(path)
}
</script>

<template>
  <v-container fluid class="fill-height pa-0">
    <v-row class="fill-height ma-0">
      <!-- 单词学习卡片 -->
      <v-col cols="12" sm="12" class="pa-4">
        <v-card class="fill-height" elevation="2" @click="navigateTo('/study')">
          <v-card-item class="fill-height d-flex flex-column justify-center">
            <v-card-title class="text-center">単語学習</v-card-title>
            <!-- <v-card-subtitle class="text-center">开始你的学习之旅</v-card-subtitle> -->
            <v-card-text class="text-center flex-grow-1 d-flex align-center justify-center">
              <v-icon size="64" color="primary">mdi-book-open-page-variant</v-icon>
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>
      <!-- 单词列表卡片 -->
      <v-col cols="12" sm="6" class="pa-4">
        <v-card class="fill-height" elevation="2" @click="navigateTo('/wordlist')">
          <v-card-item class="fill-height d-flex flex-column justify-center">
            <v-card-title class="text-center">単語リスト</v-card-title>
            <!-- <v-card-subtitle class="text-center">测试你的学习成果</v-card-subtitle> -->
            <v-card-text class="text-center flex-grow-1 d-flex align-center justify-center">
              <v-icon size="64" color="primary">mdi-list-box-outline</v-icon>
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- 考试卡片 -->
      <v-col cols="12" sm="6" class="pa-4">
        <v-card class="fill-height" elevation="2" @click="navigateTo('/test')">
          <v-card-item class="fill-height d-flex flex-column justify-center">
            <v-card-title class="text-center">テスト</v-card-title>
            <!-- <v-card-subtitle class="text-center"></v-card-subtitle> -->
            <v-card-text class="text-center flex-grow-1 d-flex align-center justify-center">
              <v-icon size="64" color="primary">mdi-file-document-edit-outline</v-icon>
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- 收藏卡片 -->
      <v-col cols="12" sm="6" class="pa-4">
        <v-card class="fill-height" elevation="2" @click="navigateTo('/important')">
          <v-card-item class="fill-height d-flex flex-column justify-center">
            <v-card-title class="text-center">重要単語</v-card-title>
            <!-- <v-card-subtitle class="text-center"></v-card-subtitle> -->
            <v-card-text class="text-center flex-grow-1 d-flex align-center justify-center">
              <v-icon size="64" color="primary">mdi-star-outline</v-icon>
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- 错题集卡片 -->
      <v-col cols="12" sm="6" class="pa-4">
        <v-card class="fill-height" elevation="2" @click="navigateTo('/mistakes')">
          <v-card-item class="fill-height d-flex flex-column justify-center">
                            <v-card-title class="text-center">ミス単語</v-card-title>
            <!-- <v-card-subtitle class="text-center">复习易错单词</v-card-subtitle> -->
            <v-card-text class="text-center flex-grow-1 d-flex align-center justify-center">
              <v-icon size="64" color="primary">mdi-close-circle-outline</v-icon>
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<style scoped>
.v-card {
  transition: transform 0.2s;
  cursor: pointer;
}

.v-card:hover {
  transform: translateY(-5px);
}
</style>