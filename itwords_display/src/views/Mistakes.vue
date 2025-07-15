<template>
  <div>
    <!-- 顶部操作栏 -->
    <v-card class="mb-4">
      <v-card-text>
        <div class="d-flex align-center">
          <div class="d-flex align-center mr-4">
            <v-select
              v-model="lessonRange.start"
              :items="lessonOptions"
              label=""
              density="compact"
              hide-details
              style="width: 150px;"
              class="mr-4"
            ></v-select>
            <span class="mr-4">～</span>
            <v-select
              v-model="lessonRange.end"
              :items="lessonOptions"
              label=""
              density="compact"
              hide-details
              style="width: 150px;"
            ></v-select>
          </div>
          
          <v-btn
            color="primary"
            variant="text"
            class="mr-4"
            @click="showAllLessons"
          >
            全部
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/study"
          >
            単語学習へ
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/test"
          >
            テストへ
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/wordlist"
          >
            単語リストへ
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/important"
          >
            重要単語へ
          </v-btn>

          <v-btn
            color="error"
            variant="text"
            class="mr-4"
            :disabled="!selectedWords.length"
            @click="confirmDelete"
          >
            削除
          </v-btn>
        </div>
      </v-card-text>
    </v-card>

    <!-- 单词列表 -->
    <v-card>
      <v-card-text v-if="loading">
        読み込み中...
      </v-card-text>
      <v-card-text v-else-if="error">
        {{ error }}
      </v-card-text>
      <v-card-text v-else-if="!words.length">
        ミス単語が見つかりません
      </v-card-text>
      <v-data-table
        v-model="selectedWords"
        :headers="headers"
        :items="words"
        :items-per-page="itemsPerPage"
        :loading="loading"
        show-select
        item-value="wordId"
        class="elevation-1"
      >
        <!-- 日语列 -->
        <template v-slot:item.japanese="{ item }">
          <div class="d-flex align-center" style="padding-left: 45px;">
            <span class="text-h6">{{ item.japanese }}</span>
            <v-btn
              icon="mdi-volume-high"
              variant="text"
              size="small"
              class="ml-2"
              @click="playAudio(item)"
            ></v-btn>
          </div>
        </template>

        <!-- 英语列 -->
        <template v-slot:item.english="{ item }">
          <span>{{ item.english }}</span>
        </template>

        <!-- 中文列 -->
        <template v-slot:item.chinese="{ item }">
          <span>{{ item.chinese }}</span>
        </template>
      </v-data-table>
    </v-card>

    <!-- 删除确认对话框 -->
    <v-dialog v-model="deleteDialog" max-width="400px">
      <v-card>
        <v-card-title class="text-h5">
          確認
          <v-spacer></v-spacer>
          <v-btn 
            icon="mdi-close" 
            variant="text" 
            @click="deleteDialog = false"
          ></v-btn>
        </v-card-title>
        <v-card-text>
          選択した単語をミス単語から削除しますか？
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="error"
            variant="text"
            @click="deleteSelectedWords"
          >
            削除
          </v-btn>
          <v-btn
            color="primary"
            variant="text"
            @click="deleteDialog = false"
          >
            キャンセル
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 提示信息 -->
    <v-snackbar
      v-model="snackbar.show"
      :color="snackbar.color"
      :timeout="3000"
    >
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>

<script>
import wordService from '@/api/wordService'
import { useUserStore } from '@/store/user'

export default {
  name: 'Mistakes',
  setup() {
    const userStore = useUserStore();
    return {
      userStore
    };
  },
  data: () => ({
    lessonRange: {
      start: '1',
      end: '31'
    },
    itemsPerPage: 10,
    deleteDialog: false,
    selectedWords: [],
    snackbar: {
      show: false,
      text: '',
      color: 'info'
    },
    lessonOptions: Array.from({ length: 31 }, (_, i) => ({
      title: `Lesson ${i + 1}`,
      value: String(i + 1)
    })),
    headers: [
      {
        title: '　　　 日本語',
        key: 'japanese',
        sortable: true,
        width: '30%'
      },
      {
        title: '中国語',
        key: 'chinese',
        sortable: true,
        width: '35%'
      },
      {
        title: '英語',
        key: 'english',
        sortable: true,
        width: '35%'
      }
    ],
    words: [],
    loading: false,
    error: null
  }),
  watch: {
    lessonRange: {
      handler(newRange) {
        this.fetchWords()
      },
      deep: true
    }
  },
  created() {
    this.fetchWords()
  },
  methods: {
    // 获取错题列表
    async fetchWords() {
      this.loading = true
      this.error = null
      try {
        const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
        if (!userId) {
          this.showSnackbar('ログインしてください', 'error')
          return
        }
        const response = await wordService.listWrong({ userId })
        if (response && response.data) {
          this.words = response.data
        } else {
          this.words = []
        }
      } catch (error) {
                  this.error = error.response?.data?.message || 'ミス単語の取得に失敗しました'
        this.words = []
      } finally {
        this.loading = false
      }
    },

    // 播放日语发音
    async playAudio(word) {
      try {
        const utterance = new SpeechSynthesisUtterance(word.japanese)
        utterance.lang = 'ja-JP'
        utterance.rate = 1.0
        utterance.pitch = 1.0
        
        await new Promise((resolve, reject) => {
          utterance.onend = resolve
          utterance.onerror = reject
          window.speechSynthesis.speak(utterance)
        })
      } catch (error) {
        this.showSnackbar('音声の再生に失敗しました。ブラウザの設定を確認してください', 'error')
      }
    },

    // 显示所有课程
    showAllLessons() {
      this.lessonRange = {
        start: '1',
        end: '31'
      }
    },

    // 确认删除
    confirmDelete() {
      if (this.selectedWords.length > 0) {
        this.deleteDialog = true
      }
    },

    // 删除选中的单词
    async deleteSelectedWords() {
      try {
        const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
        if (!userId) {
          this.showSnackbar('ログインしてください', 'error')
          return
        }
        for (const word of this.selectedWords) {
          console.log('正在删除单词:', word)
          const deleteDTO = {
            userId,
            wordId: Number(word)
          }
          console.log('删除请求参数:', deleteDTO)
          const response = await wordService.deleteWrong(deleteDTO)
          console.log('删除响应:', response)
        }
        this.selectedWords = []
        this.showSnackbar('選択した単語を削除しました', 'success')
        // 删除成功后刷新数据
        await this.fetchWords()
      } catch (error) {
        console.error('删除失败:', error)
        this.showSnackbar(error.response?.data?.message || '削除に失敗しました', 'error')
      }
      this.deleteDialog = false
    },

    // 显示提示信息
    showSnackbar(text, color = 'info') {
      this.snackbar = {
        show: true,
        text,
        color
      }
    }
  }
}
</script>

<style scoped>
.v-data-table {
  background: white;
}

/* 优化表格中单词显示 */
.v-data-table :deep(.v-data-table__td) {
  padding: 12px 16px !important;
  vertical-align: middle !important;
}

/* 日语单词列样式优化 */
.v-data-table :deep(.v-data-table__td:first-child) {
  min-width: 200px;
}

.v-data-table :deep(.text-h6) {
  word-wrap: break-word;
  word-break: break-all;
  line-height: 1.4;
  max-width: 180px;
  white-space: normal;
}

/* 英语和中文列样式优化 */
.v-data-table :deep(.v-data-table__td:nth-child(2)),
.v-data-table :deep(.v-data-table__td:nth-child(3)) {
  word-wrap: break-word;
  word-break: break-word;
  line-height: 1.4;
  white-space: normal;
}

/* 提高表格行高 */
.v-data-table :deep(.v-data-table__tr) {
  min-height: 60px;
}

/* 表头字体加大 */
.v-data-table :deep(.v-data-table__th) {
  font-size: 1.05rem !important;
  font-weight: 600 !important;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .v-data-table :deep(.text-h6) {
    font-size: 1.1rem !important;
    max-width: 120px;
  }
  
  .v-data-table :deep(.v-data-table__td) {
    padding: 8px 12px !important;
  }
}
</style> 