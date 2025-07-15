<template>
  <div class="study-container">
    <!-- 顶部操作栏 -->
    <v-card class="mb-4">
      <v-card-text>
        <div class="d-flex align-center">
          <div class="d-flex align-center mr-4">
            <!-- <span class="mr-2">从</span> -->
            <v-select
              v-model="lessonRange.start"
              :items="lessonOptions"
              label=""
              density="compact"
              hide-details
              style="width: 150px;"
              class="mr-2"
            ></v-select>
            <span class="mr-2">〜</span>
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
            color="primary"
            variant="text"
            class="mr-4"
            @click="shuffleWords"
          >
            ランダム
          </v-btn>
        </div>
      </v-card-text>
    </v-card>

    <!-- Loading State -->
    <v-card v-if="loading" class="word-card" elevation="2">
      <v-card-text class="text-center">
        <v-progress-circular indeterminate></v-progress-circular>
        <div class="mt-4">読み込み中...</div>
      </v-card-text>
    </v-card>

    <!-- Error State -->
    <v-card v-else-if="error" class="word-card" elevation="2">
      <v-card-text class="text-center text-error">
        {{ error }}
      </v-card-text>
    </v-card>

    <!-- Empty State -->
    <v-card v-else-if="!words.length" class="word-card" elevation="2">
      <v-card-text class="text-center">
        単語が見つかりません
      </v-card-text>
    </v-card>

    <!-- Word Display Card -->
    <v-card v-else class="word-card" elevation="2">
      <!-- Left Navigation Button -->
      <v-btn
        icon="mdi-chevron-left"
        size="large"
        @click="previousWord"
        :disabled="currentIndex === 0"
        class="nav-btn nav-btn-left"
      ></v-btn>

      <!-- Word Content -->
      <v-card-text class="text-center">
        <!-- Japanese Word -->
        <div class="japanese-word" v-show="showJapanese">
          <h1 class="text-h2 mb-8">{{ currentWord.japanese }}</h1>
          <v-btn
            icon="mdi-volume-high"
            variant="text"
            size="large"
            @click="playAudio"
            class="mb-4"
          ></v-btn>
        </div>
        
        <!-- English and Chinese Translation -->
        <div class="translations">
          <h2 class="text-h4 mb-4">{{ currentWord.english }}</h2>
          <h3 class="text-h5 text-grey">{{ currentWord.chinese }}</h3>
        </div>

        <!-- Progress -->
        <div class="progress mt-8">
          {{ currentIndex + 1 }} / {{ words.length }}
        </div>

        <!-- Star Icon -->
        <v-btn
          icon="mdi-star"
          variant="text"
          size="large"
          :color="currentWord.isImportant ? 'warning' : 'grey'"
          @click="toggleImportant"
          class="star-btn"
        ></v-btn>
      </v-card-text>

      <!-- Right Navigation Button -->
      <v-btn
        icon="mdi-chevron-right"
        size="large"
        @click="nextWord"
        :disabled="currentIndex === words.length - 1"
        class="nav-btn nav-btn-right"
      ></v-btn>
    </v-card>

    <!-- Toggle Button -->
    <div class="text-center mt-6 d-flex justify-center align-center" style="gap: 12px;">
      <v-btn
        color="secondary"
        prepend-icon="mdi-list-box"
        to="/wordlist"
        class="mx-1"
      >
        単語リストへ
      </v-btn>
      <v-btn
        color="secondary"
        prepend-icon="mdi-lead-pencil"
        to="/test"
        class="mx-1"
      >
        テストへ
      </v-btn>
      <v-btn
        color="primary"
        class="mx-1"
        @click="toggleJapanese"
      >
        {{ showJapanese ? '日本語を隠す' : '日本語を見る' }}
      </v-btn>
      <v-btn
        color="secondary"
        prepend-icon="mdi-star"
        to="/important"
        class="mx-1"
      >
        重要単語へ
      </v-btn>
      <v-btn
        color="secondary"
        prepend-icon="mdi-close-circle"
        to="/mistakes"
        class="mx-1"
      >
                              ミス単語へ
      </v-btn>
    </div>
  </div>
</template>

<script>
import wordService from '@/api/wordService'

export default {
  name: 'Study',
  data: () => ({
    lessonRange: {
      start: '1',
      end: '31'
    },
    lessonOptions: Array.from({ length: 31 }, (_, i) => ({
      title: `Lesson ${i + 1}`,
      value: String(i + 1)
    })),
    showJapanese: true,
    currentIndex: 0,
    words: [],
    loading: false,
    error: null,
    importantWordIds: []
  }),
  computed: {
    currentWord() {
      return this.words[this.currentIndex] || {}
    }
  },
  watch: {
    lessonRange: {
      handler(newRange) {
        this.fetchWords()
      },
      deep: true
    }
  },
  async created() {
    await this.fetchWords();
    await this.fetchImportantWords();
    this.updateCurrentWordImportant();
  },
  methods: {
    // 获取单词列表
    async fetchWords() {
      this.loading = true
      this.error = null
      try {
        console.log('Fetching words with range:', this.lessonRange)
        let response
        // 如果选择了全部课程，使用 getAllWords
        if (this.lessonRange.start === '1' && this.lessonRange.end === '31') {
          response = await wordService.getAllWords()
        } else {
          // 否则使用 getWordsByCategories
          response = await wordService.getWordsByCategories(
            this.lessonRange.start,
            this.lessonRange.end
          )
        }
        console.log('Received response:', response)
        if (response && response.data && response.data.data) {
          this.words = response.data.data
          this.currentIndex = 0
          console.log('Updated words:', this.words)
        } else {
          console.error('Invalid response format:', response)
          this.words = []
        }
      } catch (error) {
        this.error = error.response?.data?.message || '単語リストの取得に失敗しました'
        console.error('Error fetching words:', error)
        if (error.response) {
          console.error('Error response:', error.response)
        }
        this.words = []
      } finally {
        this.loading = false
      }
    },

    // 播放日语发音
    async playAudio() {
      console.log('Playing audio for:', this.currentWord.japanese)
      
      try {
        // 使用 Web Speech API
        const utterance = new SpeechSynthesisUtterance(this.currentWord.japanese)
        utterance.lang = 'ja-JP'
        utterance.rate = 1.0
        utterance.pitch = 1.0
        
        // 等待语音播放完成
        await new Promise((resolve, reject) => {
          utterance.onend = resolve
          utterance.onerror = reject
          window.speechSynthesis.speak(utterance)
        })
        
        console.log('Speech synthesis completed')
      } catch (error) {
        console.error('Speech synthesis failed:', error)
        this.$nextTick(() => {
          this.$vuetify.snackbar = {
            show: true,
            text: '音声の再生に失敗しました。ブラウザの設定を確認してください。',
            color: 'error'
          }
        })
      }
    },

    // 显示所有课程
    showAllLessons() {
      this.lessonRange = {
        start: '1',
        end: '31'
      }
    },

    // 打乱单词顺序
    shuffleWords() {
      const array = [...this.words]
      for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]]
      }
      this.words = array
      this.currentIndex = 0
    },

    toggleJapanese() {
      this.showJapanese = !this.showJapanese
    },

    nextWord() {
      if (this.currentIndex < this.words.length - 1) {
        this.currentIndex++
        this.updateCurrentWordImportant()
      }
    },

    previousWord() {
      if (this.currentIndex > 0) {
        this.currentIndex--
        this.updateCurrentWordImportant()
      }
    },

    async fetchImportantWords() {
      const userStr = localStorage.getItem('user')
      if (!userStr) return
      const user = JSON.parse(userStr)
      if (!user.userId) return
      const res = await wordService.getImportantWords(user.userId)
      if (res.data && res.data.data) {
        this.importantWordIds = res.data.data.map(item => item.wordId)
      } else {
        this.importantWordIds = []
      }
    },

    updateCurrentWordImportant() {
      if (this.currentWord) {
        this.currentWord.isImportant = this.importantWordIds.includes(this.currentWord.wordId || this.currentWord.id)
      }
    },

    async toggleImportant() {
      const userStr = localStorage.getItem('user')
      if (!userStr) {
        this.$nextTick(() => {
          this.$vuetify.snackbar = {
            show: true,
            text: 'ログインしてください',
            color: 'error'
          }
        })
        return
      }
      const user = JSON.parse(userStr)
      if (!user.userId) {
        this.$nextTick(() => {
          this.$vuetify.snackbar = {
            show: true,
            text: 'ユーザー情報が不完全です。再度ログインしてください',
            color: 'error'
          }
        })
        return
      }
      if (!this.currentWord.isImportant) {
        // 添加到重点单词
        const userNoteDTO = {
          userId: user.userId,
          wordId: this.currentWord.wordId || this.currentWord.id,
          memo: null
        }
        const response = await wordService.addToImportantWords(userNoteDTO)
        if (response.data && response.data.code === 200) {
          this.currentWord.isImportant = true
          this.importantWordIds.push(this.currentWord.wordId || this.currentWord.id)
          this.$nextTick(() => {
            this.$vuetify.snackbar = {
              show: true,
              text: '重要単語に追加しました',
              color: 'success'
            }
          })
        }
      } else {
        // 从重点单词列表中删除
        const deleteDTO = {
          userId: user.userId,
          wordId: this.currentWord.wordId || this.currentWord.id
        }
        const response = await wordService.deleteFromImportantWords(deleteDTO)
        if (response.data && response.data.code === 200) {
          this.currentWord.isImportant = false
          this.importantWordIds = this.importantWordIds.filter(id => id !== (this.currentWord.wordId || this.currentWord.id))
          this.$nextTick(() => {
            this.$vuetify.snackbar = {
              show: true,
              text: '重要単語から削除しました',
              color: 'success'
            }
          })
        }
      }
    }
  }
}
</script>

<style scoped>
.study-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.word-card {
  padding: 60px 40px 40px 40px; /* 增加上内边距从40px到60px */
  border-radius: 12px;
  height: 450px; /* 增加高度以适应更大的内边距 */
  width: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.japanese-word {
  margin-bottom: 40px;
  height: 120px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* 优化日语单词显示，支持长单词分行 */
.japanese-word h1 {
  word-wrap: break-word;
  word-break: break-all;
  line-height: 1.2;
  text-align: center;
  max-width: 100%;
  padding: 0 20px;
}

.translations {
  margin-top: 40px;
  height: 120px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* 优化翻译文本显示，支持长文本分行 */
.translations h2,
.translations h3 {
  word-wrap: break-word;
  word-break: break-word;
  line-height: 1.3;
  text-align: center;
  max-width: 100%;
  padding: 0 20px;
}

.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  z-index: 1;
}

.nav-btn-left {
  left: 20px;
}

.nav-btn-right {
  right: 20px;
}

.progress {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 1.1rem;
  color: rgba(0, 0, 0, 0.6);
}

.mx-2 {
  margin: 0 8px;
}

.mt-6 {
  margin-top: 48px;
}

.star-btn {
  position: absolute;
  bottom: 20px;
  right: 20px;
  z-index: 1;
}

/* 响应式设计 - 在较小屏幕上进一步优化 */
@media (max-width: 600px) {
  .word-card {
    padding: 50px 20px 30px 20px;
    height: 400px;
  }
  
  .japanese-word h1 {
    font-size: 2.5rem !important;
  }
  
  .translations h2 {
    font-size: 1.8rem !important;
  }
  
  .translations h3 {
    font-size: 1.4rem !important;
  }
}
</style> 